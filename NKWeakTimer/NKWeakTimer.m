//
//  NKWeakTimer.m
//  NKWeakTimer
//
//  Created by Near on 2016/12/23.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import "NKWeakTimer.h"


typedef NS_ENUM(NSUInteger, NKWeakTimerScheduledType) {
    NKWeakTimerScheduledTypeSEL,
    NKWeakTimerScheduledTypeBlock,
};


CGFloat const NKWeakTimerMinimumInterval = 0.01f;
CGFloat const NKWeakTimerToleranceRate = 0.1f;


@interface NKWeakTimer ()
#pragma mark interface
//Time type, Block or SEL
@property (nonatomic) NKWeakTimerScheduledType scheduledType;
@property (nonatomic, readwrite) NSTimeInterval timeInterval;
@property (nonatomic) BOOL repeats;

@property (nonatomic, readwrite) NSTimeInterval tolerance;
@property (nonatomic, readwrite, getter=isValid) BOOL valid;

//SEL Property
@property (nonatomic, weak) id aTarget;
@property (nonatomic, assign) SEL aSelector;
@property (nonatomic, readwrite) id userInfo;

//Block Property
@property (nonatomic, copy) void (^timeBlock)(NKWeakTimer *timer);


#pragma mark Private
//queue of timer implement
@property (nonatomic, strong) dispatch_queue_t dispatchQueue;
//timer source
@property (nonatomic, strong) dispatch_source_t dispatchSource;
//private queue
@property (nonatomic, strong) dispatch_queue_t dispatchPrivateSerialQueue;
//is implementing, if false, out of this timer queue
@property (nonatomic) BOOL canImplement;

@end

@implementation NKWeakTimer
@synthesize fireDate = _fireDate;

- (void)dealloc {
    [self invalidate];
    NSLog(@"__dealloc__%@<%p>__", self.class, self);
}

#pragma mark scheduledTimer
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)repeats {
    return [self scheduledTimerWithFireDate:nil timeInterval:interval target:aTarget selector:aSelector userInfo:userInfo repeats:repeats dispatchQueue:dispatch_get_main_queue()];
}

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval userInfo:(nullable id)userInfo repeats:(BOOL)repeats block:(void (^)(NKWeakTimer *timer))block {
    return [self scheduledTimerWithFireDate:nil timeInterval:interval userInfo:userInfo repeats:repeats dispatchQueue:dispatch_get_main_queue() block:block];
}

+(instancetype)scheduledTimerWithFireDate:(NSDate *)fireDate timeInterval:(NSTimeInterval)interval target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)repeats dispatchQueue:(dispatch_queue_t)dispatchQueue {
    NKWeakTimer *weakTimer = [[NKWeakTimer alloc] initWithTimeInterval:interval target:aTarget selector:aSelector userInfo:userInfo block:nil type:NKWeakTimerScheduledTypeSEL fireDate:fireDate repeats:repeats dispatchQueue:dispatchQueue];
    return weakTimer;
}

+(instancetype)scheduledTimerWithFireDate:(NSDate *)fireDate timeInterval:(NSTimeInterval)interval userInfo:(id)userInfo repeats:(BOOL)repeats dispatchQueue:(dispatch_queue_t)dispatchQueue block:(void (^)(NKWeakTimer * _Nonnull))block {
    NKWeakTimer *weakTimer = [[NKWeakTimer alloc] initWithTimeInterval:interval target:nil selector:nil userInfo:userInfo block:block type:NKWeakTimerScheduledTypeBlock fireDate:fireDate repeats:repeats dispatchQueue:dispatchQueue];
    return weakTimer;
}

- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval
                              target:(id)target
                            selector:(SEL)selector
                            userInfo:(nullable id)userInfo
                               block:(void (^)(NKWeakTimer *timer))block
                                type:(NKWeakTimerScheduledType)scheduledType
                            fireDate:(nullable NSDate *)date
                             repeats:(BOOL)repeats
                       dispatchQueue:(dispatch_queue_t)dispatchQueue {
    
    if (scheduledType == NKWeakTimerScheduledTypeSEL) {
        NSParameterAssert(target);
        NSParameterAssert(selector);
    } else if (scheduledType == NKWeakTimerScheduledTypeBlock) {
        NSParameterAssert(block);
    }
    NSParameterAssert(dispatchQueue);
    
    self = [super init];
    self.scheduledType = scheduledType;
    self.timeInterval = MAX(NKWeakTimerMinimumInterval, timeInterval);
    self.dispatchQueue = dispatchQueue;
    self.repeats = repeats;
    self.userInfo = userInfo;
    
    switch (scheduledType) {
        case NKWeakTimerScheduledTypeSEL:
            self.aTarget = target;
            self.aSelector = selector;
            break;
            
        case NKWeakTimerScheduledTypeBlock:
            self.timeBlock = block;
            break;
    }
    
    //setup fire time, if the fire date less than 1.0f, put away
    _fireDate = date;
    NSTimeInterval fileTime = 0;
    if (date && [date timeIntervalSinceReferenceDate] - [NSDate timeIntervalSinceReferenceDate] > NKWeakTimerMinimumInterval) {
        fileTime = [date timeIntervalSinceReferenceDate] - [NSDate timeIntervalSinceReferenceDate];
    }
    
    //use the memory as the queue label
    self.dispatchPrivateSerialQueue = dispatch_queue_create([[NSString stringWithFormat:@"com.kong.nate.weakTimer<%p>", self] cStringUsingEncoding:NSASCIIStringEncoding], DISPATCH_QUEUE_SERIAL);
    
    _tolerance = MIN(self.timeInterval * NKWeakTimerToleranceRate, NKWeakTimerMinimumInterval);
    
    [self setupTimerWithFireDate:fileTime];
    
    return self;
}

- (void)setupTimerWithFireDate:(NSTimeInterval)fireDate {
    //create Dispatch Source
    self.dispatchSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                                 0,
                                                 0,
                                                 self.dispatchPrivateSerialQueue);
    
    dispatch_source_set_timer(self.dispatchSource,
                              dispatch_time(DISPATCH_TIME_NOW, (fireDate < NKWeakTimerMinimumInterval ? self.timeInterval : fireDate) * NSEC_PER_SEC),
                              (uint64_t)self.timeInterval * NSEC_PER_SEC,
                              (uint64_t)self.tolerance * NSEC_PER_SEC
                              );
    
    switch (self.scheduledType) {
        case NKWeakTimerScheduledTypeSEL: {
            dispatch_source_set_event_handler(self.dispatchSource, ^{
                [self fireSEL];
            });
        }
            break;
            
        case NKWeakTimerScheduledTypeBlock: {
            dispatch_source_set_event_handler(self.dispatchSource, ^{
                [self fireBlock];
            });
        }
            break;
    }
    
    self.canImplement = true;
    self.valid = true;
    dispatch_resume(self.dispatchSource);
}


#pragma mark Fire
- (void)fire {
    switch (_scheduledType) {
        case NKWeakTimerScheduledTypeSEL:
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self.aTarget performSelector:self.aSelector withObject:self];
#pragma clang diagnostic pop
            break;
            
        case NKWeakTimerScheduledTypeBlock:
            self.timeBlock(self);
            break;
    }
}

- (void)fireBlock {
    if (_canImplement) {
        _canImplement = false;
        __weak NKWeakTimer *weakSelf = self;
        dispatch_async(self.dispatchQueue, ^{
            __strong NKWeakTimer *strongSelf = weakSelf;
            strongSelf.timeBlock(strongSelf);
            
            if (!strongSelf.repeats) {
                [strongSelf invalidate];
            }
            
            strongSelf.canImplement = true;
        });
        
    }
}

- (void)fireSEL {
    if (_canImplement) {
        _canImplement = false;
        __weak NKWeakTimer *weakSelf = self;
        dispatch_async(self.dispatchQueue, ^{
            __strong NKWeakTimer *strongSelf = weakSelf;
            if (strongSelf.aTarget) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [strongSelf.aTarget performSelector:strongSelf.aSelector withObject:strongSelf];
#pragma clang diagnostic pop
            } else {
                [strongSelf invalidate];
            }
            
            if (!strongSelf.repeats) {
                [strongSelf invalidate];
            }
            
            strongSelf.canImplement = true;
        });
    }
}

- (void)invalidate {
    @synchronized(self) {
        if (_valid) {
            _valid = false;
            dispatch_source_t dispatchSource = _dispatchSource;
            dispatch_async(_dispatchPrivateSerialQueue, ^{
                dispatch_source_cancel(dispatchSource);
            });
        }
    }
}


#pragma mark Property
- (void)setFireDate:(NSDate *)fireDate {
    @synchronized (self) {
        if (fireDate && [fireDate timeIntervalSinceReferenceDate] - [NSDate timeIntervalSinceReferenceDate] > NKWeakTimerMinimumInterval) {
            _fireDate = fireDate;
            NSTimeInterval fireTime = [fireDate timeIntervalSinceReferenceDate] - [NSDate timeIntervalSinceReferenceDate];
            dispatch_source_t dispatchSource = _dispatchSource;
            [self invalidate];
            [self setupTimerWithFireDate:fireTime];
            dispatchSource = nil;
        }
    }
}

- (NSDate *)fireDate {
    @synchronized (self) {
        return _fireDate;
    }
}

//- (void)setTolerance:(NSTimeInterval)tolerance {
//    @synchronized(self) {
//        if (tolerance != _tolerance && tolerance >= NKWeakTimerMinimumInterval && tolerance <= MIN(_timeInterval, 1)) {
//            _tolerance = tolerance;
//            dispatch_source_t dispatchSource = _dispatchSource;
//            [self invalidate];
//            [self setupTimerFromFireDate:false];
//            dispatchSource = nil;
//        }
//    }
//}


#pragma mark description
/**
 *  Ststus in Debug
 */
- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"__%@<%p>__timeInterval: %f, isValid: %@, repeatable: %@", NSStringFromClass([self class]), self, self.timeInterval, self.isValid ? @"TRUE" : @"FALSE", self.repeats ? @"TRUE" : @"FALSE"];
}


@end
