NKCWeakTimer
===========

## Description

`NKCWeakTimer` can be used as `NSTimer`, but do not retain Target.
`NKCWeakTimer` is implemented by `GCD`, and all behaves I had considered like `NSTimer`.

>You can use `NKCWeakTimer` as other Object, strong it, and `NKCWeakTimer` need not to release in the `dealloc` method.
>`NKCWeakTimer` will invoke `invalidate` method when retain count equre to 0, and release itself automatic.

## How to Use

Create an `NKCWeakTimer` object with below class method, `NKCWeakTimer` scheduled automatic. 
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

- Manually:

Simply add the files `NKCWeakTimer.h` and `NKCWeakTimer.m` to your project.

## Compatibility

- Requires ARC. If you want to use it in a project without ARC, mark ```NKCWeakTimer``` with the linker flag ```-fobjc-arc```.
- Supports iOS iOS8+ and Mac OSX 10.10+.