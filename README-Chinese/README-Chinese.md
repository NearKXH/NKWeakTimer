NKWeakTimer
===========

## 概述

`NKWeakTimer` 使用方式和 `NSTimer` 一样, 但不会强引用 target。`NKWeakTimer` 用 `GCD` 实现, 功能与 `NSTimer` 一致。

- `NKWeakTimer` 在调度时会强引用自身, 但不会强引用`target`目标. 循环引用会在调用`invalidate`方法后被打破。
- `NKWeakTimer` 在释放时会自动调用 `invalidate` 方法。
- 重复定时器，`NKWeakTimer` 如果是通过`SEL`创建的，会在`target`释放时自动调用`invalidate`跟随释放。但是通过`Block`创建的定时器，必须在`target`释放时调用`invalidate`来释放。

## 使用

用以下方法创建 `NKWeakTimer` 实例，并开始计数。 
- SEL方式:

```objc
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                        target:(id)aTarget
                                      selector:(SEL)aSelector
                                      userInfo:(nullable id)userInfo
                                       repeats:(BOOL)repeats;
```

- Block方式:

```objc
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      userInfo:(nullable id)userInfo
                                       repeats:(BOOL)repeats
                                         block:(void (^)(NKWeakTimer *timer))block;
```

### 安装

- 使用 CocoaPods:

在 `Podfile` 中加入:

```
pod 'NKWeakTimer'
```

- 手动：把 `NKWeakTimer.h` 和 `NKWeakTimer.m` 复制到项目中.

### 通用性

- 支持 iOS iOS8+ 和 Mac OSX 10.10+.
- ARC环境下使用. MRC环境下, 用`-fobjc-arc` 标注 `NKWeakTimer`.
