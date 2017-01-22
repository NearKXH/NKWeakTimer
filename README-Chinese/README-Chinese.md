NKCWeakTimer
===========

## 概述

`NKCWeakTimer` 使用方式和 `NSTimer` 一样, 但不会强引用 target。

`NKCWeakTimer` 用 `GCD` 实现, 功能与 `NSTimer` 一致.

>你可以像普通的 `NSObject` 一样使用 `NKCWeakTimer`, 作为实例的 属性，并且不需要在 `dealloc` 中释放.
>
>*当引用计数器0时, `NKCWeakTimer` 会自动调用 `invalidate` 停止计时，并释放。 你也可以手动调用 `invalidate` 方法，停止计时。*

## 使用

用以下方法创建 `NKCWeakTimer` 实例，并立即开始计数。 
SEL方式:

```objc
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                        target:(id)aTarget
                                      selector:(SEL)aSelector
                                      userInfo:(nullable id)userInfo
                                       repeats:(BOOL)repeats;
```

Block方式:

```objc
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      userInfo:(nullable id)userInfo
                                       repeats:(BOOL)repeats
                                         block:(void (^)(NKCWeakTimer *timer))block;
```

## 安装

- 使用 CocoaPods:

在 `Podfile` 中加入:

```
pod 'NKCWeakTimer'
```

- 复制:

把 `NKCWeakTimer.h` 和 `NKCWeakTimer.m` 复制到项目中.

## 通用性

- ARC环境下使用. MRC环境下, 用```-fobjc-arc`` 标注 ```NKCWeakTimer```.
- 支持 iOS iOS8+ 和 Mac OSX 10.10+.
