//
//  NKCWeakTimer.m
//  NKCWeakTimer
//
//  Created by Near on 2016/12/23.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NKCWeakTimer.h"

typedef NS_ENUM(NSUInteger, NKCWeakTimerScheduledType) {
    NKCWeakTimerScheduledTypeSEL,
    NKCWeakTimerScheduledTypeBlock,
};

@interface NKCWeakTimer ()
#pragma mark interface
//Time type, Block or SEL
@property (nonatomic) NKCWeakTimerScheduledType scheduledType;
@property (nonatomic, readwrite) NSTimeInterval timeInterval;
@property (nonatomic) BOOL repeats;

//SEL Property
@property (nonatomic, weak) id aTarget;
@property (nonatomic, assign) SEL aSelector;
@property (nonatomic, readwrite) id userInfo;

//Block Property
@property (nonatomic, copy) void (^timeBlock)(NKCWeakTimer *timer);

@property (readwrite, getter=isValid) BOOL valid;

#pragma mark Private
//fire time
@property (nonatomic, assign) NSTimeInterval firePrivateTimeInterval;

//queue of timer implement
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;
//timer source
@property (nonatomic, strong) dispatch_source_t dispatchSource;
//private queue
@property (nonatomic, strong) dispatch_queue_t dispatchPrivateSerialQueue;
//is implementing, if false, out of this timer queue
@property (nonatomic) BOOL canImplement;

@end

@implementation NKCWeakTimer
static NSString *const kNKCWeakTimerDispatchQueueLabel = @"com.gmail.kongxh.near.kWeakTimer";

@synthesize tolerance = _tolerance;
@synthesize canImplement = _canImplement;
@synthesize valid = _valid;
@synthesize fireDate = _fireDate;

- (void)dealloc {
    [self invalidate];
    NSLog(@"-- dealloc -- NKCWeakTimer --");
}

#pragma mark scheduledTimer
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)repeats {
    NKCWeakTimer *weakTimer = [[NKCWeakTimer alloc] initWithTimeInterval:interval target:aTarget selector:aSelector userInfo:userInfo block:nil type:NKCWeakTimerScheduledTypeSEL fireDate:nil repeats:repeats dispatchQueue:dispatch_get_main_queue()];
    return weakTimer;
}
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval userInfo:(nullable id)userInfo repeats:(BOOL)repeats block:(void (^)(NKCWeakTimer *timer))block {
    NKCWeakTimer *weakTimer = [[NKCWeakTimer alloc] initWithTimeInterval:interval target:nil selector:nil userInfo:userInfo block:block type:NKCWeakTimerScheduledTypeBlock fireDate:nil repeats:repeats dispatchQueue:dispatch_get_main_queue()];
    return weakTimer;
}

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)repeats fireDate:(nullable NSDate *)fireDate dispatchQueue:(dispatch_queue_t)dispatchQueue {
    NKCWeakTimer *weakTimer = [[NKCWeakTimer alloc] initWithTimeInterval:interval target:aTarget selector:aSelector userInfo:userInfo block:nil type:NKCWeakTimerScheduledTypeSEL fireDate:fireDate repeats:repeats dispatchQueue:dispatchQueue];
    return weakTimer;
}

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval userInfo:(nullable id)userInfo repeats:(BOOL)repeats block:(void (^)(NKCWeakTimer *timer))block fireDate:(nullable NSDate *)fireDate dispatchQueue:(dispatch_queue_t)dispatchQueue {
    NKCWeakTimer *weakTimer = [[NKCWeakTimer alloc] initWithTimeInterval:interval target:nil selector:nil userInfo:userInfo block:block type:NKCWeakTimerScheduledTypeBlock fireDate:fireDate repeats:repeats dispatchQueue:dispatchQueue];
    return weakTimer;
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval
                              target:(id)target
                            selector:(SEL)selector
                            userInfo:(nullable id)userInfo
                               block:(void (^)(NKCWeakTimer *timer))block
                                type:(NKCWeakTimerScheduledType)scheduledType
                            fireDate:(nullable NSDate *)date
                             repeats:(BOOL)repeats
                       dispatchQueue:(dispatch_queue_t)dispatchQueue {
    
    if (scheduledType == NKCWeakTimerScheduledTypeSEL) {
        NSParameterAssert(target);
        NSParameterAssert(selector);
    } else if (scheduledType == NKCWeakTimerScheduledTypeBlock) {
        NSParameterAssert(block);
    }
    NSParameterAssert(dispatchQueue);
    
    self = [super init];
    self.scheduledType = scheduledType;
    self.timeInterval = timeInterval < 0.01 ? 0.1 : timeInterval;
    self.dispatchQueue = dispatchQueue;
    self.repeats = repeats;
    
    _canImplement = true;
    _valid = false;
    switch (scheduledType) {
        case NKCWeakTimerScheduledTypeSEL:
            self.aTarget = target;
            self.aSelector = selector;
            self.userInfo = userInfo;
            break;
            
        case NKCWeakTimerScheduledTypeBlock:
            self.timeBlock = block;
            self.userInfo = userInfo;
            break;
    }
    
    //setup fire time, if the fire date less than 1.0f, put away
    if (!date || [date timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970] < 1.0f) {
        self.firePrivateTimeInterval = 0;
    } else {
        _fireDate = date;
        self.firePrivateTimeInterval = [date timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970];
    }
    
    //use the memory as the queue label
    self.dispatchPrivateSerialQueue = dispatch_queue_create([[kNKCWeakTimerDispatchQueueLabel copy] cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
    //create Dispatch Source
    self.dispatchSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                                 0,
                                                 0,
                                                 self.dispatchPrivateSerialQueue);
    
    _tolerance = self.timeInterval * 0.1;
    [self setupTimer];
    return self;
}

- (void)setupTimer {
    dispatch_source_set_timer(self.dispatchSource,
                              dispatch_time(DISPATCH_TIME_NOW, (self.timeInterval + self.firePrivateTimeInterval) * NSEC_PER_SEC),
                              (uint64_t)self.timeInterval * NSEC_PER_SEC,
                              (uint64_t)self.tolerance * NSEC_PER_SEC
                              );
    self.firePrivateTimeInterval = 0;
    
    __weak NKCWeakTimer *weakSelf = self;
    if (self.scheduledType == NKCWeakTimerScheduledTypeSEL) {
        dispatch_source_set_event_handler(self.dispatchSource, ^{
            [weakSelf fireSEL];
        });
    } else if (self.scheduledType == NKCWeakTimerScheduledTypeBlock) {
        dispatch_source_set_event_handler(self.dispatchSource, ^{
            [weakSelf fireBlock];
        });
    }
    self.valid = true;
    dispatch_resume(self.dispatchSource);
}

- (void)invalidate {
    @synchronized(self) {
        if (self.isValid) {
            self.valid = false;
            dispatch_source_t dispatchSource = self.dispatchSource;
            dispatch_async(self.dispatchPrivateSerialQueue, ^{
                dispatch_source_cancel(dispatchSource);
            });
        }
    }
}

#pragma mark Fire
- (void)fire {
    __weak NKCWeakTimer *weakSelf = self;
    if (self.scheduledType == NKCWeakTimerScheduledTypeSEL) {
        dispatch_async(self.dispatchQueue, ^{
            weakSelf.canImplement = false;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [weakSelf.aTarget performSelector:weakSelf.aSelector withObject:weakSelf];
#pragma clang diagnostic pop
            weakSelf.canImplement = true;
        });
    } else if (self.scheduledType == NKCWeakTimerScheduledTypeBlock) {
        dispatch_async(self.dispatchQueue, ^{
            weakSelf.canImplement = false;
            weakSelf.timeBlock(weakSelf);
            weakSelf.canImplement = true;
        });
    }
}

- (void)fireBlock {
    if (self.canImplement) {
        self.canImplement = false;
        __weak NKCWeakTimer *weakSelf = self;
        dispatch_async(self.dispatchQueue, ^{
            weakSelf.timeBlock(weakSelf);
            weakSelf.canImplement = true;
        });
        
        if (!self.repeats) {
            [self invalidate];
        }
    }
}

- (void)fireSEL {
    if (self.canImplement) {
        self.canImplement = false;
        __weak NKCWeakTimer *weakSelf = self;
        dispatch_async(self.dispatchQueue, ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [weakSelf.aTarget performSelector:weakSelf.aSelector withObject:weakSelf];
#pragma clang diagnostic pop
            weakSelf.canImplement = true;
        });
        
        if (!self.repeats) {
            [self invalidate];
        }
    }
}

#pragma mark Property
- (void)setFireDate:(NSDate *)fireDate {
    @synchronized (self) {
        if (fireDate && [fireDate timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970] > 1.0f) {
            _fireDate = fireDate;
            self.firePrivateTimeInterval = [fireDate timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970];
            [self invalidate];
            [self setupTimer];
        }
    }
}

- (NSDate *)fireDate {
    @synchronized (self) {
        return _fireDate;
    }
}

- (BOOL)isValid {
    @synchronized (self) {
        return _valid;
    }
}

- (void)setValid:(BOOL)valid {
    @synchronized (self) {
        _valid = valid;
    }
}

- (BOOL)canImplement {
    @synchronized(self) {
        return _canImplement;
    }
}

- (void)setCanImplement:(BOOL)canImplement {
    @synchronized (self) {
        _canImplement = canImplement;
    }
}

- (void)setTolerance:(NSTimeInterval)tolerance
{
    @synchronized(self) {
        if (tolerance != _tolerance && tolerance >= 0 && tolerance < self.timeInterval * 0.5f) {
            _tolerance = tolerance;
            [self invalidate];
            [self setupTimer];
        }
    }
}

- (NSTimeInterval)tolerance
{
    @synchronized(self) {
        return _tolerance;
    }
}

#pragma mark System
/**
 *  Ststus in Debug
 */
- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"\n<%@ %p> \n\ttime_interval = %f\n\tisValid = %@",
            NSStringFromClass([self class]),
            self,
            self.timeInterval,
            self.isValid ? @"TRUE" : @"FALSE"];
}

@end
