---
layout: post
status: publish
published: true
title: Animating Arbitrary KeyPaths
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: What I want to do is take a collection of data objects that the layer owns,
  animate each of their scales independently, and have the layer do its animation
  thing. But how do we animate based on changes in properties of things in a layer's
  collection?
wordpress_id: 812
wordpress_url: http://robnapier.net/blog/?p=812
date: 2012-12-17 21:44:41.000000000 -05:00
categories:
- iphone
tags: []
---
During <a href="http://cocoaconf.com/raleigh-2012/home">CocoaConf-2012-Raleigh</a>, I discussed my PinchView from <a href="http://robnapier.net/blog/laying-out-text-with-coretext-547">Laying out text with Core Text</a>. It's a text view that squeezes the glyphs towards your finger when you touch it. I built it to demonstrate per-glyph layout in Core Text. While demonstrating it, I was pretty unsatisfied with how it looked when you touched it or let go. When you drag your finger on the view, the glyphs move around like water. It's quite pretty. But when you initially touch the screen, the glyphs suddenly jump to their new locations, and then they jump back when you release the screen. Well, that's no good. So I wanted to add animations.

But here's the thing: what do you animate? While you do want to animate the glyph positions, you're not doing it directly. The location of each glyph is dependent on the location of the current touch. What you want to animate is how much the touch impacts the glyph positions. A quick look over CALayer's list of animatable properties confirmed that there's nothing like that. But no problem, I added a custom property called `touchPointScale` and animated that. (I cover animating custom properties in the Layers chapter of <a href="http://iosptl.com">iOS:PTL</a>, and I still have to pull out that chapter every time to remind myself how to do it. Ole Begemann has a <a href="http://stackoverflow.com/questions/2395382/animating-a-custom-property-of-calayer-subclass">good, quick writeup</a> on Stack Overflow.)

OK, so great. But one comment I got at CocoaConf was that it should handle multitouch. So I started playing with that, but now I had a problem. I could have lots of touches, so my single `touchPointScale` doesn't...er...scale. What I want to do is take a collection of `TouchPoint` objects that the layer owns, animate each of their scales independently, and have the layer do its animation thing. But how do we animate based on changes in properties of things in a layer's collection?
<a id="more"></a><a id="more-812"></a>

*The sample code is available on <a href="https://github.com/rnapier/richtext-coretext/tree/master/PinchText">github</a>.*

First, we have `TouchPoint` objects. These are just trivial data objects. The `identifier` here happens to be the address of the object, but it could be any unique string.

``` objc
@interface TouchPoint : NSObject
@property (nonatomic, readwrite, strong) UITouch *touch;
@property (nonatomic, readwrite, assign) CGPoint point;
@property (nonatomic, readwrite, assign) CGFloat scale;

+ (TouchPoint *)touchPointForTouch:(UITouch *)touch inView:(UIView *)view scale:(CGFloat)scale;
- (NSString *)identifier;
@end
```

Then we have `PinchTextLayer`, which has a collection of `TouchPoint` objects:

``` objc
@property (nonatomic, readwrite, strong) NSMutableDictionary *touchPointsForIdentifier;
```

The thing we want to animate is "the `scale` of the touch point with a given identifier." In order to animate something, it needs to be something you can call `setValue:forKeyPath:` on. And that brings us to the power of KVC and dictionaries.

Say you have this code:

``` objc
self.dict[@"somekey"] = @"somevalue";
```

You can also write that this way:

``` objc
[self setValue:@"somevalue" forKeyPath:@"dict.somekey"];
```

And if you have this code:

``` objc
self.dict[@"somekey"].prop = @"someValue";
```

You can write that this way:

``` objc
[self setValue:@"somevalue" forKeyPath:@"dict.somekey.prop"];
```

And that means that things held in dictionaries can be animated pretty easily because they can be accessed via `setValue:forKeyPath:`. First, you need to tell the layer that changes on your dictionary impact drawing:

``` objc
+ (BOOL)needsDisplayForKey:(NSString *)key {
  if ([key isEqualToString:@"touchPointForIdentifier"]) {
    return YES;
  }
  else {
    return [super needsDisplayForKey:key];
  }
}
```

This applies to all key paths that start with `touchPointForIdentifier`. And because we're not animating `touchPointForIdentifier` itself, we don't have to make it `@dynamic`. We do need to copy it in `initWithLayer:` of course:

``` objc
- (id)initWithLayer:(id)layer {
  self = [super initWithLayer:layer];
  ...
  [self setTouchPointForIdentifier:[[layer touchPointForIdentifier] copy]];
  return self;
}
```

And that's just about it. We can now treat the key path "touchPointForIdentifier.&lt;identifier&gt;.scale" as an animatable property just like `position` or `opacity`.

``` objc
- (void)addTouches:(NSSet *)touches inView:(UIView *)view scale:(CGFloat)scale {
  for (UITouch *touch in touches) {
    TouchPoint *touchPoint = [TouchPoint touchPointForTouch:touch inView:view scale:scale];
    NSString *keyPath = [self touchPointScaleKeyPathForTouchPoint:touchPoint];

    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:keyPath];
    anim.fromValue = @0;
    anim.toValue = @(touchPoint.scale);
    [self addAnimation:anim forKey:keyPath];

    [self.touchPointForIdentifier setObject:touchPoint forKey:touchPoint.identifier];
  }
}

- (NSString *)touchPointScaleKeyPathForTouchPoint:(TouchPoint *)touchPoint {
  return [NSString stringWithFormat:@"touchPointForIdentifier.%@.scale", touchPoint.identifier];
}
```

Side note: Along the way, I also developed a technique for animating custom properties (without any storage behind them, implemented by custom methods) by overriding `setValue:forKeyPath:`. If you think that might be useful, you can see it in <a href="https://github.com/rnapier/richtext-coretext/tree/4eb482dcfe2340f09d553c707a5b3b2a4116ff63">github</a>, but so far I haven't thought of any cases where it's better than using the dictionary.
