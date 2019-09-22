NKWeakTimer
===========



## Description

`NKWeakTimer` can be used as `NSTimer`, but do not retain target. So target can retain it as normal object and set  property by `strong`. `NKWeakTimer` is implemented by `GCD`, and all features are similar to `NSTimer`.

- `NKWeakTimer` retains itself when scheduled, but do not ratain `target`. Retain circle will be broken after `invalidate` called or is not repeatable. 
- `NKWeakTimer` invokes `invalidate` method automatically when released.
- `NKWeakTimer` , which is repeatable, releases itself automatically when target released if it is scheduled by `SEL`. So target do not need to call `invalidate` on `dealloc`. But `invalidate` must be called on `dealloc` when target released if it is scheduled by `Block`. 

##### [中文说明](https://github.com/NearKXH/NKWeakTimer/tree/master/README-Chinese/README-Chinese.md)

## How to Use

#### Creates and returns a new `NKWeakTimer` object initialized, and schedules it on the main thread.

- Using SEL as below:

```objc
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                        target:(id)aTarget
                                      selector:(SEL)aSelector
                                      userInfo:(nullable id)userInfo
                                       repeats:(BOOL)repeats;
```

- Using Block as below:

```objc
+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      userInfo:(nullable id)userInfo
                                       repeats:(BOOL)repeats
                                         block:(void (^)(NKWeakTimer *timer))block;
```

#### Creates and returns a new `NKWeakTimer` object initialized, and schedules it on the specified queue.

```objc
+ (instancetype)scheduledTimerWithFireDate:(nullable NSDate *)fireDate timeInterval:(NSTimeInterval)interval target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)repeats dispatchQueue:(dispatch_queue_t)dispatchQueue;

+ (instancetype)scheduledTimerWithFireDate:(nullable NSDate *)fireDate timeInterval:(NSTimeInterval)interval userInfo:(nullable id)userInfo repeats:(BOOL)repeats dispatchQueue:(dispatch_queue_t)dispatchQueue block:(void (^)(NKWeakTimer *timer))block;
```

### Installation

- Using CocoaPods:

Just add this line to your `Podfile`:

```
pod 'NKWeakTimer'
```

- Manually:

Simply add the files `NKWeakTimer.h` and `NKWeakTimer.m` to project.

### Compatibility

- Supports iOS iOS8+ and Mac OSX 10.10+.
- Requires ARC. If you want to use it in a project without ARC, mark `NKWeakTimer.m` with the linker flag `-fobjc-arc`.

### License
This project is used under the <a href="http://opensource.org/licenses/MIT" target="_blank">MIT</a> license agreement. For more information, see <a href="https://github.com/NearKXH/NKWeakTimer/blob/master/LICENSE">LICENSE</a>.
