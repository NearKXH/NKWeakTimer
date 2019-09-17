//
//  NKWeakTimer.h
//  NKWeakTimer
//
//  Created by Near on 2016/12/23.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  NKWeakTimer can be used as NSTimer, but do not retain Target
 *  It is implemented by GCD, and all features had considered as NSTimer
 *
 */

extern CGFloat NKWeakTimerToleranceRate;    // 0.1f
extern CGFloat NKWeakTimerMinimumInterval;  // 0.01f

@interface NKWeakTimer : NSObject

/**
 *  Creates a timer with default parameters, timer schedule and run when finished.
 *
 *  @note It's safe to retain the return timer.
 *  @note You must make sure aTarget and aSelector is not nil, otherwise throwing error by NSParameterAssert.
 *  SEL well be invoked in dispatch_get_main_queue(), tolerance is set as interval * NKWeakTimerToleranceRate
 *
 *  @param interval the seconds between firing. Interval set to NKWeakTimerMinimumInterval if it is less than NKWeakTimerMinimumInterval. SEL will be invoked, approximately `timeInterval` seconds from the time you call this method.
 *  @param repeats if TRUE, SEL will be invoked on aTarget until timer deallocated or invalidate called. If FALSE, it will only be invoked once, or None if the timer deallocated or invalidate called before invoked.
 *  @see invalidate.
 */
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                        target:(id)aTarget
                                      selector:(SEL)aSelector
                                      userInfo:(nullable id)userInfo
                                       repeats:(BOOL)repeats;


/**
 *  Creates a timer with default parameters, timer schedule and run when finished.
 *
 *  @note It's safe to retain the return timer.
 *  @note You must make sure block is not nil, otherwise throwing error by NSParameterAssert
 *  Block well be invoked in dispatch_get_main_queue(), tolerance is set as interval * NKWeakTimerToleranceRate
 *
 *  @param interval the seconds between firing. Interval set to NKWeakTimerMinimumInterval if it is less than NKWeakTimerMinimumInterval. Block will be invoked, approximately `timeInterval` seconds from the time you call this method.
 *  @param repeats if TRUE, SEL will be invoked on aTarget until timer deallocated or until you call invalidate. If FALSE, it will only be invoked once, Or None if the timer deallocated or you call invalidate before invoked.
 *  @param block NKWeakTimer do not retain the block, instead copying the block, you should use __weak to ensure the block without strong target.
 *  @see invalidate.
 */
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      userInfo:(nullable id)userInfo
                                       repeats:(BOOL)repeats
                                         block:(void (^)(NKWeakTimer *timer))block;


/**
 *  Timer schedule and run as soon as finished.
 *
 *  @param fireDate a further fire time, now if nil.
 *  @param dispatchQueue The dispatch_queue_t for the SEL or Block to run in.
 *  @note dispatchQueue must not be nil, otherwise throwing error by NSParameterAssert
 */
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)repeats fireDate:(nullable NSDate *)fireDate dispatchQueue:(dispatch_queue_t)dispatchQueue;

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval userInfo:(nullable id)userInfo repeats:(BOOL)repeats fireDate:(nullable NSDate *)fireDate dispatchQueue:(dispatch_queue_t)dispatchQueue block:(void (^)(NKWeakTimer *timer))block;


/**
 *  invoke the SEL or Block. 
 *  SEL or Block will be invoked after the current SEL/Block finished immediately.
 *  Timer will fire although it had stopped or is not repeatable.
 */
- (void)fire;

/**
 *  set a further fire time.
 *  @note fireDate must larger than now + 0.05s, otherwise it do not effect
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
 *  You can call this method on repeatable timers in order to stop it from running.
 *  It will be called when NKWeakTimer deallocated automaticly.
 */
- (void)invalidate;
@property (readonly, getter=isValid) BOOL valid;

@property (nonatomic, readonly, nullable) id userInfo;


@end

NS_ASSUME_NONNULL_END
