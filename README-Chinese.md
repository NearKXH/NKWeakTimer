NKCWeakTimer
===========

##[中文版本](https://gitlab.com/iOS-Project/NKCWeakTimer/blob/master/README-Chinese.md).

## 概述

`NKCWeakTimer` 使用方式和 `NSTimer` 一样, 但不会强引用 target。

`NKCWeakTimer` 用 `GCD` 实现, 功能与 `NSTimer` 一致.

>You can use `NKCWeakTimer` as normal NSObject, strong it, and `NKCWeakTimer` do not need to release in the `dealloc` method.
>
>*`NKCWeakTimer` invoke `invalidate` method when `retainCount` equre to 0, and release itself automatically. Of course, you can invoke `invalidate` method whenever you need.*

## How to Use

Create an `NKCWeakTimer` object with below class method, `NKCWeakTimer` scheduled automatically. 

Using SEL as below:

```objc
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                        target:(id)aTarget
                                      selector:(SEL)aSelector
                                      userInfo:(nullable id)userInfo
                                       repeats:(BOOL)repeats;
```

Using Block as below:

```objc
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      userInfo:(nullable id)userInfo
                                       repeats:(BOOL)repeats
                                         block:(void (^)(NKCWeakTimer *timer))block;
```

## Installation

- Using CocoaPods:

Just add this line to your `Podfile`:

```
pod 'NKCWeakTimer'
```

- Manually:

Simply add the files `NKCWeakTimer.h` and `NKCWeakTimer.m` to your project.

## Compatibility

- Requires ARC. If you want to use it in a project without ARC, mark ```NKCWeakTimer``` with the linker flag ```-fobjc-arc```.
- Supports iOS iOS8+ and Mac OSX 10.10+.
