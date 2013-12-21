---
layout: post
status: publish
published: true
title: Clipping a CGRect to a CGPath
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: Clipping a CGRect to an arbitrary CGPath is one of the key steps for laying
  out text within an arbitrary CGPath. We can perform this clipping by drawing into
  a bitmap context and examining the resulting pixels.
wordpress_id: 531
wordpress_url: http://robnapier.net/blog/?p=531
date: 2010-09-09 10:49:07.000000000 -04:00
categories:
- cocoa
- iphone
tags: []
---
I've been playing with Core Text recently, and one of the things I wanted to do was layout text in an arbitrary CGPath. On Mac, you'd do this with NSLayoutManager, but iOS doesn't have that so we have to build our own. I'll discuss Core Text more later, but one of the steps along this problem is how to clip a CGRect to a CGPath. I found several discussions of finding CGPath intersections, all explaining the basic technique. Draw the things you care about into a bitmap context and then inspect the pixels to see where they overlap. Clear enough, but it was hard to find a small code sample that demonstrated this with Core Graphics.

For my purposes, I want the first full-height rectangle within the intersection of the line rectangle and the CGPath. Later I will expand this code to find all full-height rectangles within the intersection (there can be more than one), but this is enough to demonstrate the point.
<!-- more -->
First, we quickly clip the rectangle to the bounding box of the CGPath using `CGPathGetBoundingBox()`. In iOS 4, they've added `CGPathGetPathBoundingBox()`, which can create a tighter box if you have control points outside your path, but I don't know yet if there's a performance trade-off for using it.

    CGRect rect = someRect();
    CGPathRef path = somePath();

    CGRect boundingBox = CGPathGetBoundingBox(path);
    CGRect clippedRect = CGRectIntersection(boundingBox, rect);
	clippedRect = clipRectToPath(clippedRect, path);

You could do this first-pass clipping in `clipRectToPath()`, but my actual code uses `CGMakeRect()` to build up the clippedRect because I'm making them in a loop.

Without further fanfare, here is `clipRectToPath()`:


    CGRect clipRectToPath(CGRect rect, CGPathRef path)
    {
    	size_t width = floorf(rect.size.width);
    	size_t height = floorf(rect.size.height);
    	uint8_t *bits = calloc(width * height, sizeof(*bits));
    	CGContextRef bitmapContext =
            CGBitmapContextCreate(bits, 
                                  width,
                                  height,
                                  sizeof(*bits) * 8,
                                  width,
                                  NULL,
                                  kCGImageAlphaOnly);
    	CGContextSetShouldAntialias(bitmapContext, NO);

    	CGContextTranslateCTM(bitmapContext, -rect.origin.x, -rect.origin.y);
    	CGContextAddPath(bitmapContext, path);
    	CGContextFillPath(bitmapContext);
	
    	BOOL foundStart = NO;
    	NSRange range = NSMakeRange(0, 0);
    	NSUInteger x = 0;
    	for (; x < width; ++x)
    	{
    		BOOL isGoodColumn = YES;
    		for (NSUInteger y = 0; y < height; ++y)
    		{
    			if (bits[y * width + x] < 128)
    			{
    				isGoodColumn = NO;
    				break;
    			}
    		}

    		if (isGoodColumn && ! foundStart)
    		{
    			foundStart = YES;
    			range.location = x;
    		}
    		else if (!isGoodColumn && foundStart)
    		{
    			break;
    		}
    	}
    	if (foundStart)
    	{
            // x is 1 past the last full-height column
    		range.length = x - range.location - 1;
    	}
	
    	CGContextRelease(bitmapContext);
    	free(bits);
	
    	CGRect clipRect = 
            CGRectMake(rect.origin.x + range.location, rect.origin.y, 
                range.length, rect.size.height);	
    	return clipRect;
    }

First, we work out the size of the image and create a buffer to hold the bytes, one byte per pixel. We create an alpha-only bitmap context. We don't need color; just black and white, and we don't want anti-aliasing since we just care about clipped and not clipped. We translate the context to match our box and draw our path.

Now we have a two-dimensional array of bytes which are either 0 or 255. We walk through each column, row by row, to see if there are any uncolored pixels. If there are, then this is not a full-height column, and we skip it. Once we find a full-height column, we continue looking until we find one that isn't. If we find it, we mark that as the end of our range (we'll subtract one later). Finally, we create our new rectangle using our range.

Later I will expand this to return a CFArrayRef rather than a single CGRect. That way I can return multiple rectangles if the path intersects the rectangle multiple times. That just requires appending the rectangle to a list and starting over rather than calling 'break' in the last "else if" clause.

This technique is applicable to many other problems, such as finding the intersection of an arbitrary set of CGPaths. If you can draw it, you can use this approach to find the holes or the overlaps.

There are several optimizations available here. In particular, we could create a single CGBitmapContext and a single buffer large enough for our largest rectangle. That would get rid of some memory churn.
