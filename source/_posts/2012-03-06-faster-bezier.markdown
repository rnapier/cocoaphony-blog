---
layout: post
status: publish
published: true
title: Even Faster Bezier
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: When last we looked at Bézier curve calculations, we were able to calculate
  five million points in about 0.6s (~8.3Mp/s or megapoints-per-second). That's 1000
  points per curve, 100 curves, at 50fps. That was 5x faster than the original `-Os`
  optimized function. But we're just getting warmed up. We haven't yet gotten half
  of the performance available. In this installment, we'll look at improving our algorithm.
wordpress_id: 722
wordpress_url: http://robnapier.net/blog/?p=722
date: 2012-03-06 12:53:40.000000000 -05:00
categories:
- cocoa
- iphone
- performance
tags: []
---
When <a href="http://robnapier.net/blog/fast-bezier-intro-701">last we looked at Bézier curve calculations</a>, we were able to calculate five million points in about 0.6s (~8.3Mp/s or megapoints-per-second). That's 1000 points per curve, 100 curves, at 50fps. That was 5x faster than the original `-Os` optimized function. But we're just getting warmed up. We haven't yet gotten half of the performance available.

<a id="more"></a><a id="more-722"></a>
In this installment, we'll look at improving our algorithm. The code is available on <a href="https://github.com/rnapier/cocoaphony/tree/master/BezierPerf">github</a>.

We tried the Accelerate framework, but it didn't help us. The cost of the function calls obliterated our gains. What can we do? First, let's look at the code again, and see if we're doing anything foolish.

	static inline CGFloat BezierNoPow(CGFloat t, CGFloat P0, CGFloat P1, CGFloat P2, CGFloat P3) {
	  return
	    (1-t)*(1-t)*(1-t) * P0
	    + 3 * (1-t)*(1-t) * t * P1
	    + 3 * (1-t) * t*t * P2
	    + t*t*t * P3;
	}

	unsigned int copyBezierNoPow(CGPoint P0, CGPoint P1, CGPoint P2, CGPoint P3, CGPoint **results) {
	  *results = calloc(kSteps + 1, sizeof(struct CGPoint));

	  for (unsigned step = 0; step <= kSteps; ++step) {
	    CGFloat x = BezierNoPow((CGFloat)step/(CGFloat)kSteps, P0.x, P1.x, P2.x, P3.x);
	    CGFloat y = BezierNoPow((CGFloat)step/(CGFloat)kSteps, P0.y, P1.y, P2.y, P3.y);
	    (*results)[step] = CGPointMake(x, y);
	  }
	  return kSteps + 1;
	}

Notice how we're recalculating a lot of things. For example, we calculate `(1-t)*(1-t)*(1-t)` twice with the same `t`. That can't be good. What if we factor out the part that doesn't change between *x* and *y*?

	unsigned int copyBezierXY(CGPoint P0, CGPoint P1, CGPoint P2, CGPoint P3, CGPoint **results) {
	  *results = malloc((kSteps + 1) * sizeof(struct CGPoint));

	  for (unsigned step = 0; step <= kSteps; ++step) {
	    CGFloat t = (CGFloat)step/(CGFloat)kSteps;
    
	    CGFloat C0 = (1-t)*(1-t)*(1-t); // * P0
	    CGFloat C1 = 3 * (1-t)*(1-t) * t; // * P1
	    CGFloat C2 = 3 * (1-t) * t*t; // * P2
	    CGFloat C3 = t*t*t; // * P3;

	    CGPoint point = {
	      C0*P0.x + C1*P1.x + C2*P2.x + C3*P3.x,
	      C0*P0.y + C1*P1.y + C2*P2.y + C3*P3.y
	    };

	    (*results)[step] = point;
	  }
	  return kSteps + 1;
	}

Hey, that gets us from 0.6s to 0.5s (10Mp/s). A 17% improvement's pretty good. But let's think about this some more. The values `t` can take are exactly dependent on `kSteps`, which is a constant for the program. And since the `C` variables depend only on `t`, that means they're a fixed set as well. We should only have to calculate them once for the whole program. That seems a lot of work we don't need to do. Let's see how it turns out.

	unsigned int copyBezierTable(CGPoint P0, CGPoint P1, CGPoint P2, CGPoint P3, CGPoint **results) {
	  *results = malloc((kSteps + 1) * sizeof(struct CGPoint));
  
	  static CGFloat C0[kSteps] = {0};
	  static CGFloat C1[kSteps] = {0};
	  static CGFloat C2[kSteps] = {0};
	  static CGFloat C3[kSteps] = {0};
	  static int sInitialized = 0;
	  if (!sInitialized) {
	    for (unsigned step = 0; step <= kSteps; ++step) {
	      CGFloat t = (CGFloat)step/(CGFloat)kSteps;
	      C0[step] = (1-t)*(1-t)*(1-t); // * P0
	      C1[step] = 3 * (1-t)*(1-t) * t; // * P1
	      C2[step] = 3 * (1-t) * t*t; // * P2
	      C3[step] = t*t*t; // * P3;
	    }
	    sInitialized = 1;
	  }
  
	  for (unsigned step = 0; step <= kSteps; ++step) {
	    CGPoint point = {
	      C0[step]*P0.x + C1[step]*P1.x + C2[step]*P2.x + C3[step]*P3.x,
	      C0[step]*P0.y + C1[step]*P1.y + C2[step]*P2.y + C3[step]*P3.y
	    };
	    (*results)[step] = point;
	  }
	  return kSteps + 1;
	}

0.16s. 31Mp/s. That's over 3x faster by just calculating the piece that changes.

**Lesson 2: In most cases, your biggest improvements will come from changing your algorithm. Whenever possible, get expensive things out of loops. Don't make a calculation fast if you can get rid of the calculation entirely. Remember that if you're called many times, that's the same as a loop.**

The cost of this is 4 floats (16 bytes) per step to store the constants. So for a 1000 step curve, that's less than 16kB. Not a bad investment on iOS. This cost is for as many curves as you want, as long as they all use the same step size. Of course, if you want different numbers of steps, you could just pass a scale variable to calculate every other point, every fourth point, etc. But by the time we're done optimizing this (and there's still plenty of performance left to unlock), you may find that it's faster and easier just to calculate the same number of points for all curves.

There is another common way to speed up Bézier calculation. Hannu Kankaanpää wrote an excellent article explaining <a href="http://www.niksula.hut.fi/~hkankaan/Homepages/bezierfast.html">forward differencing using a Taylor series</a>. His approach is fast. About 50-60% faster than `copyBezierXY()`. But `copyBezierTable()` is about twice as fast as forward differencing if you calculate a lot of curves with the same step size. Forward differencing is fast if you have one incredibly expensive curve to calculate (say a large Bézier surface). But it loses when you need to calculate a lot of curves. Factoring out everything but the points themselves into a pre-calcuated table lets you skip almost all the work. And that's the goal.

We *still* haven't pulled out Instruments, and we're still writing in portable C. I wonder what we might get if we go off-road and write directly for the NEON coprocessor. Yes, that means we're moving onto ARM assembler in the next post. Think you can't beat the compiler? Think it's not worth it to try? Think again.
