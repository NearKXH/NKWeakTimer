//
//  NKWeakTimer.h
//  NKWeakTimer
//
//  Created by Near on 2016/12/23.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  NKWeakTimer can be used as NSTimer, but do not retain Target
 *  It is implemented by GCD, and all features are similar to NSTimer
 *
 */

extern double const NKWeakTimerToleranceRate;      // 0.1f
extern double const NKWeakTimerMinimumInterval;    // 0.01f


@interface NKWeakTimer : NSObject

/**
 *  Creates and returns a new NKWeakTimer object initialized with the specified target and SEL object, and schedules it on the main thread.
 *
 *  @note It's safe to retain the returned timer.
 *  @note aTarget and aSelector can not be nil, otherwise throwing error by NSParameterAssert.
 *  SEL well be invoked on the main thread, tolerance is set as interval * NKWeakTimerToleranceRate
 *
 *  @param interval  The number of seconds between firings of the timer. If it is less than NKWeakTimerMinimumInterval, this method chooses the nonnegative value of NKWeakTimerMinimumInterval seconds instead. SEL will be invoked, approximately `timeInterval` seconds from this method called.
 *  @param repeats  If YES, the timer will repeatedly reschedule itself until invalidated. If NO, the timer will be invalidated after it fires.
 *
 *  @see invalidate.
 */
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)repeats;


/**
 *  Creates and returns a new NKWeakTimer object initialized with the specified block object, and schedules it on the main thread.
 *
 *  @note It's safe to retain the returned timer.
 *  @note Block can not be nil, otherwise throwing error by NSParameterAssert
 *  Block well be invoked on the main thread, tolerance is set as interval * NKWeakTimerToleranceRate
 *
 *  @param interval  The number of seconds between firings of the timer. If it is less than NKWeakTimerMinimumInterval, this method chooses the nonnegative value of NKWeakTimerMinimumInterval seconds instead. Block will be invoked, approximately `timeInterval` seconds from this method called.
 *  @param repeats  If YES, the timer will repeatedly reschedule itself until invalidated. If NO, the timer will be invalidated after it fires.
 *  @param block  The execution body of the timer; the timer itself is passed as the parameter to this block when executed to aid in avoiding cyclical references
 *
 *  @see invalidate.
 */
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval userInfo:(nullable id)userInfo repeats:(BOOL)repeats block:(void (^)(NKWeakTimer *timer))block;


/**
 *  Creates and returns a new NKWeakTimer object initialized with the specified target and SEL object, and schedules it on the specified thread.
 *
 *  @note It's safe to retain the returned timer.
 *  @note aTarget and aSelector can not be nil, otherwise throwing error by NSParameterAssert.
 *  SEL well be invoked on the specified queue, tolerance is set as interval * NKWeakTimerToleranceRate
 *  @note dispatchQueue must not be nil, otherwise throwing error by NSParameterAssert
 *
 *  @param fireDate  The time at which the timer should first fire.
 *  @param interval  The number of seconds between firings of the timer. If it is less than NKWeakTimerMinimumInterval, this method chooses the nonnegative value of NKWeakTimerMinimumInterval seconds instead. SEL will be invoked, approximately `timeInterval` seconds from this method called.
 *  @param repeats  If YES, the timer will repeatedly reschedule itself until invalidated. If NO, the timer will be invalidated after it fires.
 *  @param dispatchQueue  The dispatch_queue_t for the SEL to run on.
 *
 *  @see invalidate.
 */
+ (instancetype)scheduledTimerWithFireDate:(nullable NSDate *)fireDate timeInterval:(NSTimeInterval)interval target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)repeats dispatchQueue:(dispatch_queue_t)dispatchQueue;


/**
 *  Creates and returns a new NKWeakTimer object initialized with the specified block object, and schedules it on the specified thread.
 *
 *  @note It's safe to retain the returned timer.
 *  @note Block can not be nil, otherwise throwing error by NSParameterAssert
 *  Block well be invoked on the specified queue, tolerance is set as interval * NKWeakTimerToleranceRate
 *  @note dispatchQueue must not be nil, otherwise throwing error by NSParameterAssert
 *
 *  @param fireDate  The time at which the timer should first fire.
 *  @param interval  The number of seconds between firings of the timer. If it is less than NKWeakTimerMinimumInterval, this method chooses the nonnegative value of NKWeakTimerMinimumInterval seconds instead. Block will be invoked, approximately `timeInterval` seconds from this method called.
 *  @param repeats  If YES, the timer will repeatedly reschedule itself until invalidated. If NO, the timer will be invalidated after it fires.
 *  @param block  The execution body of the timer; the timer itself is passed as the parameter to this block when executed to aid in avoiding cyclical references
 *  @param dispatchQueue  The dispatch_queue_t for the block to run on.
 *
 *  @see invalidate.
 */
+ (instancetype)scheduledTimerWithFireDate:(nullable NSDate *)fireDate timeInterval:(NSTimeInterval)interval userInfo:(nullable id)userInfo repeats:(BOOL)repeats dispatchQueue:(dispatch_queue_t)dispatchQueue block:(void (^)(NKWeakTimer *timer))block;


/**
 *  invoke the SEL or Block. 
 *  SEL or Block will be invoked after the current SEL/Block finished immediately.
 *  Timer will fire although it had stopped or is not repeatable.
 */
- (void)fire;

/**
 *  set a further fire time.
 *  @note fireDate must larger than now + NKWeakTimerMinimumInterval, otherwise it do not effect
 */
@property (copy) NSDate *fireDate;
@property (nonatomic, readonly) NSTimeInterval timeInterval;


/**
 *  As described in NSTimer below
 *  Setting a tolerance for a timer allows it to fire later than the scheduled fire date, improving the ability of the system to optimize for increased power savings and responsiveness. The timer may fire at any time between its scheduled fire date and the scheduled fire date plus the tolerance. The timer will not fire before the scheduled fire date. For repeating timers, the next fire date is calculated from the original fire date regardless of tolerance applied at individual fire times, to avoid drift. The default value is zero, which means no additional tolerance is applied. The system reserves the right to apply a small amount of tolerance to certain timers regardless of the value of this property.
 *  Setting a tolerance for a timer allows it to fire later than the scheduled fire date, improving the ability of the system to optimize for increased power savings and responsiveness. The timer may fire at any time between its scheduled fire date and the scheduled fire date plus the tolerance. The timer will not fire before the scheduled fire date. For repeating timers, the next fire date is calculated from the original fire date regardless of tolerance applied at individual fire times, to avoid drift. The default value is zero, which means no additional tolerance is applied. The system reserves the right to apply a small amount of tolerance to certain timers regardless of the value of this property.
 */
@property (nonatomic, readonly) NSTimeInterval tolerance;


/**
 *  Stop repeatable timer
 *  @note  It will be called when NKWeakTimer deallocated automaticly.
 */
- (void)invalidate;
@property (nonatomic, readonly, getter=isValid) BOOL valid;

@property (nonatomic, readonly, nullable) id userInfo;


@end

NS_ASSUME_NONNULL_END
