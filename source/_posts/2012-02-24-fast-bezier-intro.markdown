---
layout: post
status: publish
published: true
title: Introduction to Fast Bezier (and trying the Accelerate.framework)
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: So you want to hand-calculate Bézier curves. Good for you. It comes up more
  often then you'd think on iOS. We'll discuss how to do it simply, and how to do
  it faster.
wordpress_id: 701
wordpress_url: http://robnapier.net/blog/?p=701
date: 2012-02-24 14:22:46.000000000 -05:00
categories:
- cocoa
- iphone
- performance
---
[If you want the answer to last time's homework, skip to the end.]

So you want to hand-calculate Bézier curves. Good for you. It comes up more often then you'd think on iOS, even though `UIBezierPath` is supposed to do it all for you. The truth is, sometimes you need the numbers yourself. For instance if you want to calculate intersections, or you want to draw text along the curve (like in <a href="https://github.com/rnapier/ios5ptl/tree/master/ch18/CurvyText">CurvyText</a> from <a href="http://iosptl.com">iOS:PTL</a> chapter 18).
<a id="more"></a><a id="more-701"></a>
Just as a refresher, here's the cubic Bézier function in C, written in the simplest possible way (we're only going to discuss the cubic Bézier function here):

	static CGFloat Bezier(CGFloat t, CGFloat P0, CGFloat P1, CGFloat P2, CGFloat P3) {
  	  return 
    	powf(1-t, 3) * P0
    	+ 3 * powf(1-t, 2) * t * P1
    	+ 3 * (1-t) * powf(t, 2) * P2
    	+ powf(t, 3) * P3;
	}

If you want to see this function in use, pull down CurvyText and look in <a href="https://github.com/rnapier/ios5ptl/blob/master/ch18/CurvyText/CurvyText/CurvyTextView.m">CurvyTextView.m</a>.

`P0` through `P3` are the control points. If you called `addCurveToPoint:controlPoint1:controlPoint2:`, then the starting point (wherever you "were") would be `P0`. The end point would be `P3` and the control points would be `P1` and `P2`. `t` is a value that runs from 0 to 1; we'll talk about it more in a moment. If you're still really lost, you should take time out and read the <a href="http://en.wikipedia.org/wiki/Bézier_curve">Wikipedia article on Bézier curves</a>.

The first thing to understand is that this is exactly the same function that `UIBezierPath` uses. (Well, exactly equivalent to the function they use. I'm certain they don't use this one because it's pretty inefficient as we'll see.) So when we start calculating, we're going to match `UIBezierPath` exactly. That's great because it means you can mix-and-match your code and Core Graphics and everything will match-up.

The next thing to understand is that in this form, the Bézier curve function is effectively one-dimensional. We hand it an "x" value and we get back an "x" value. We hand it a "y" value and we get back a "y" value. So we have to call it twice per point. That'll be important later for optimization purposes.

Finally, the strangest thing you need to understand is that this function is not linear for `t`. At `t=0`, the equation evaluates to `P0`. At `t=1`, the equation evaluates to `P3`. (The equation never evaluates to `P1` or `P2` since Bézier curves do not pass through these control points.) But between 0 and 1, things get much more complicated. `t=0.5` does not represent "half-way along the curve." Small changes in `t` can represent very small movement or very large movement along the curve depending on where you are on it. This fact is one of the headaches of Bézier curves.

Our goal is to figure out how to calculate Bézier very fast. So we're not going to worry much about drawing. We're just going to investigate ways to calculate this function quickly. Hopefully the process will help you when you're investigating other functions.

First, let's build a test project. You can get the full test code in <a href="https://github.com/rnapier/cocoaphony/BezierPerf">BezierPerf</a>. Starting with a basic project, you want this in `didFinishLaunchingWithOptions:` to simulate 100 curves drawn at 50 frames per second:

	#define BEZIER_FUNC copyBezierSimple

	const unsigned kFPS = 50;
	const unsigned kNumCurves = 100;

	CGPoint P0 = {50, 500};
	CGPoint P1 = {300, 300};
	CGPoint P2 = {400, 700};
	CGPoint P3 = {650, 500};

	CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
	CGPoint lastPoint = {0};
	for (unsigned i = 0; i < kFPS * kNumCurves; ++i) {
	  CGPoint *points;
	  unsigned count = BEZIER_FUNC(P0, P1, P2, P3, &points);
	  lastPoint = points[count-1];
	  free(points);
	}
	printf("Time: %f\n", CFAbsoluteTimeGetCurrent() - start);
	printf("(%f, %f)\n", lastPoint.x, lastPoint.y );
	exit(0);


Now we'll start with the simplest approach (<a href="https://github.com/rnapier/cocoaphony/blob/master/BezierPerf/BezierPerf/Bezier.c" target="_blank">Bezier.c</a>):

	unsigned int copyBezierSimple(CGPoint P0, CGPoint P1, CGPoint P2, CGPoint P3, CGPoint **results) {
	  *results = calloc(kSteps + 1, sizeof(struct CGPoint));

	  for (unsigned step = 0; step <= kSteps; ++step) {
	    CGFloat x = Bezier((CGFloat)step/(CGFloat)kSteps, P0.x, P1.x, P2.x, P3.x);
	    CGFloat y = Bezier((CGFloat)step/(CGFloat)kSteps, P0.y, P1.y, P2.y, P3.y);
	    (*results)[step] = CGPointMake(x, y);
	  }
	  return kSteps + 1;
	}

This just calls `Bezier()` twice. On my iPhone 4, in Debug mode, with 1000 points, this takes over 20 seconds to run. In Release mode (with optimizations) it takes just over 3 seconds. Wow. 6x improvement. We'll look into what it's doing later, but 3s is still no good. We need these calculations every second, and we haven't even drawn anything yet. Time to start optimizing.

It's math, so Accelerate.framework is going to make it magically fast, right? I mean, everyone knows that Accelerate uses the fancy vector hardware and that means super-duper fast. So let's do that. We'll rewrite `Bezier()` to use Accelerate. This calculates `P*B*T` as we discussed in <a href="http://robnapier.net/blog/equations-matrices-accelerate-607">the last post</a>.

	static CGFloat BezierAccelerate(CGFloat t, CGFloat P0, CGFloat P1, CGFloat P2, CGFloat P3) {
	  const CGFloat P[1][4] = {P0, P1, P2, P3};

	  static const CGFloat B[4][4] = 
	  { {-1,  3, -3, 1},
	    { 3, -6,  3, 0},
	    {-3,  3,  0, 0},
	    { 1,  0,  0, 0}};
  
	  const CGFloat T[4][1] = { powf(t, 3), powf(t, 2), t, 1 };
  
	  CGFloat PB[1][4];
	  vDSP_mmul((CGFloat*)P, 1, (CGFloat*)B, 1, (CGFloat*)PB, 1, 1, 4, 4);
  
	  CGFloat result[1][1];
	  vDSP_mmul((CGFloat*)PB, 1, (CGFloat *)T, 1, (CGFloat*)result, 1, 1, 1, 4);
  
	  return result[0][0];
	}

This is going to be great. We got rid of that long crazy function and replaced it with a couple of elegant matrix multiples running on the NEON vector processor. I can feel the speed already.

11s. In Release mode, with optimizations.

OK, so it's twice as fast as the original Debug code. But it's almost 4 times slower than just turning on `-Os` with the original function. What? Isn't Accelerate supposed to make all things faster? We haven't even tried to optimize the original `Bezier()` function, and still Accelerate is slower.

<strong>Lesson 1: Accelerate is not magic "go fast" fairy dust. It may even be slower than the simplest possible non-Accelerate implementation.</strong>

This is not to say that Accelerate isn't awesome. It can be for certain problems. But day-to-day multiplication is often not one of them.

I promised we'd talk about what `-Os` is doing and why it's giving us a 6x speedup. First, you can take a look at the code by editing the Scheme and setting the Build Configuration to Debug. Then use Product, Generate Output, Assembly File to see what happens. At the bottom of the assembler output window, you will see "Show Assembly Output For." Switching between "Running" and "Archiving" will let you compare the debug and release output.

The easiest way to navigate this output is by searching for `.thumb_func` which will help you find your functions. You can then look for `blx` to find the places you make function calls. The `.loc` entries tell you where you are in the source file (filenumber, line, column). Handy, right? In debug mode, you can see the Bezier function and the four calls to `powf()`. But in release mode, the `Bezier` function is gone entirely. It's been inlined. This is a big deal. Function calls can be expensive. This is one of the big reasons that hand-calculation can be so much faster than Accelerate. Accelerate is optimized for big matrices. For little tiny things, the cost of the function call dwarfs what you might save otherwise. Also, most Accelerate functions include fancy features like adjustable stride and parameter error checking. "Fancy features" translates into "probably slower."

Back to the assembler, note that there are only two calls to `powf()`. Where did the other calls go? Well, if you dig a little, you'll notice these lines:

	vmul.f32	d16, d0, d0
    ...
	vmul.f32	d17, d1, d1

These are squaring functions (`d0*d0 -> d16`). That is incredibly, insanely faster than `pow(x,2)`. We got rid of a lot of function calls (both calls to `Bezier` and calls to `powf`), and we replaced a very expensive squaring function with a very cheap one using `vmul`.

Which brings us to the next point. `vmul` is a NEON instruction. You don't have to use Accelerate to get NEON benefits. The compiler uses the NEON processor for all kinds of things.

So now that we know that the compiler will replace `pow(x,2)` with `x*x`, I wonder if cubing by hand is faster, too. Let's try `BezierNoPow()`:

	static CGFloat BezierNoPow(CGFloat t, CGFloat P0, CGFloat P1, CGFloat P2, CGFloat P3) {
	  return
	    (1-t)*(1-t)*(1-t) * P0
	    + 3 * (1-t)*(1-t) * t * P1
	    + 3 * (1-t) * t*t * P2
	    + t*t*t * P3;
	}

Debug: 9.7s. Nice. 50% improvement over unoptimized `powf()`.

Release: **0.6s.** 5x speedup over optimized `powf()`. **30x speedup over the original function.**

In fairness, we should try removing the `powf()` calls in the Accelerate function. That gets us to 6.5s. Still 10x slower then hand-coded.

Now 0.6s is still 60% of our available time, so it's worth digging deeper to see what else we can do to speed things up. We'll talk more about that later. We haven't really gotten warmed up yet. We haven't even launched Instruments. There is still plenty of speed we can pick up here. Read more at <a href="http://robnapier.net/blog/faster-bezier-722">Even Faster Bezier</a>.

----

For those of you who did your homework from <a href="http://robnapier.net/blog/equations-matrices-accelerate-607">last time</a>, here's the answer, this time in C, for the matrix you need to calculate the derivative (slope) of the Bézier function:

    const float Bp[4][3] = {
      {-3, 6, -3},
      {9, -12, 3},
      {-9, 6, 0},
      {3, 0, 0}
    };
