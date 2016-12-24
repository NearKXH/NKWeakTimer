//
//  NKCWeakTimer.h
//  NKCWeakTimer
//
//  Created by Near on 2016/12/23.
//  Copyright © 2016年 NearKong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NKCWeakTimer : NSObject

+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable NSDictionary *)userInfo repeats:(BOOL)yesOrNo;
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval userInfo:(nullable NSDictionary *)userInfo repeats:(BOOL)repeats block:(void (^)(NKCWeakTimer *timer))block;

- (void)fire;

@property (copy) NSDate *fireDate;
@property (nonatomic, readonly) NSTimeInterval timeInterval;//

@property NSTimeInterval tolerance;//

- (void)invalidate;
@property (readonly, getter=isValid) BOOL valid;

@property (nonatomic, readonly, nullable) NSDictionary *userInfo;

@end

NS_ASSUME_NONNULL_END
