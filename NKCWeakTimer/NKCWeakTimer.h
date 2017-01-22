//
//  NKCWeakTimer.h
//  NKCWeakTimer
//
//  Created by Near on 2016/12/23.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  NKCWeakTimer can be used as NSTimer, but do not retain Target
 *  It is implemented by GCD, and all function I had considered as NSTimer
 *  NKCWeakTimer refers to MSWeakTimer, addition Block type as implemented on iOS10, thank for them,
 *  MSWeakTimer's github version is shown below
 *  https://github.com/mindsnacks/MSWeakTimer
 *
 *  More important NKCWeakTimer github account:
 *  https://github.com/NearKXH/NKCWeakTimer
 *
 */
@interface NKCWeakTimer : NSObject

/**
 *  Creates a timer with default parameters, timer schedule and run when finish.
 *  @note It's safe to retain the returned timer by the object that is also the target.
 *  @note You must make sure aTarget and aSelector is not nil, otherwise throwing error by NSParameterAssert
 *  SEL well be invoked in dispatch_get_main_queue(), tolerance is set as interval * 0.1
 *  @param interval The number of seconds between firings of the timer. If seconds is less than or equal to 0.01, this method chooses the nonnegative value of 0.1 milliseconds instead. SEL will be invoked, approximately `timeInterval` seconds from the time you call this method.
 *  @param repeats if TRUE, SEL will be invoked on aTarget until timer deallocated or until you call invalidate. If FALSE, it will only be invoked once, Or None if the timer deallocated or you call invalidate before invoked.
 *  @see invalidate.
 */
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                        target:(id)aTarget selector:(SEL)aSelector
                                      userInfo:(nullable id)userInfo
                                       repeats:(BOOL)repeats;

/**
 *  Creates a timer with default parameters, timer schedule and run when finish.
 *  @note It's safe to retain the returned timer by the object .
 *  @note You must make sure block is not nil, otherwise throwing error by NSParameterAssert
 *  Block well be invoked in dispatch_get_main_queue(), tolerance is set as interval * 0.1
 *  @param interval The number of seconds between firings of the timer. If seconds is less than or equal to 0.01, this method chooses the nonnegative value of 0.1 milliseconds instead. SEL will be invoked, approximately `timeInterval` seconds from the time you call this method.
 *  @param repeats if TRUE, SEL will be invoked on aTarget until timer deallocated or until you call invalidate. If FALSE, it will only be invoked once, Or None if the timer deallocated or you call invalidate before invoked.
 *  @param block NKCWeakTimer do not strong the block, instead copying the block, you should use __weak to ensure the block without strong target.
 *  @see invalidate.
 */
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      userInfo:(nullable id)userInfo
                                       repeats:(BOOL)repeats
                                         block:(void (^)(NKCWeakTimer *timer))block;

/**
 *  @param dispatchQueue The dispatch_queue_t for the SEL or Block you want to run in.
 *  @note dispatchQueue must not be nil, otherwise throwing error by NSParameterAssert
 *  @see fireDate
 */
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)repeats fireDate:(nullable NSDate *)fireDate dispatchQueue:(dispatch_queue_t)dispatchQueue;
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval userInfo:(nullable id)userInfo repeats:(BOOL)repeats block:(void (^)(NKCWeakTimer *timer))block fireDate:(nullable NSDate *)fireDate dispatchQueue:(dispatch_queue_t)dispatchQueue;

/**
 *  invoke the SEL or Block. 
 *  SEL or Block will be invoked after the current SEL/Block finish immediately.
 *  It fire although timer have stopped by calling invalidate or repeats is FALSE.
 */
- (void)fire;

/**
 *  set the time running in futhur.
 *  @note fireDate must larger than [NSDate date] + 1.0f, otherwise it do not effect
 */
@property (copy) NSDate *fireDate;
@property (nonatomic, readonly) NSTimeInterval timeInterval;

/**
 *  As described in NSTimer below
 *  Setting a tolerance for a timer allows it to fire later than the scheduled fire date, improving the ability of the system to optimize for increased power savings and responsiveness. The timer may fire at any time between its scheduled fire date and the scheduled fire date plus the tolerance. The timer will not fire before the scheduled fire date. For repeating timers, the next fire date is calculated from the original fire date regardless of tolerance applied at individual fire times, to avoid drift. The default value is zero, which means no additional tolerance is applied. The system reserves the right to apply a small amount of tolerance to certain timers regardless of the value of this property.
 *  Setting a tolerance for a timer allows it to fire later than the scheduled fire date, improving the ability of the system to optimize for increased power savings and responsiveness. The timer may fire at any time between its scheduled fire date and the scheduled fire date plus the tolerance. The timer will not fire before the scheduled fire date. For repeating timers, the next fire date is calculated from the original fire date regardless of tolerance applied at individual fire times, to avoid drift. The default value is zero, which means no additional tolerance is applied. The system reserves the right to apply a small amount of tolerance to certain timers regardless of the value of this property.
 */
@property NSTimeInterval tolerance;

/**
 *  You can call this method on repeatable timers in order to stop it from running and trying
 *  to call the delegate method.
 *  It will be called when NKCWeakTimer deallocated automatic.
 */
- (void)invalidate;
@property (readonly, getter=isValid) BOOL valid;

@property (nonatomic, readonly, nullable) id userInfo;

@end

NS_ASSUME_NONNULL_END
