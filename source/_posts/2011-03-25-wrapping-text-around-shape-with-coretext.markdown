---
layout: post
status: publish
published: true
title: Wrapping text around a shape with CoreText
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: CoreText is a very powerful system for laying out text in arbitrary way.
  This is going to be a bit of a whirlwind tour about how to attack that with CTFramesetter.
wordpress_id: 540
wordpress_url: http://robnapier.net/blog/?p=540
date: 2011-03-25 12:15:19.000000000 -04:00
categories:
- cocoa
tags: []
---
CoreText is a very powerful system for laying out text in arbitrary ways. This is going to be a bit of a whirlwind tour of it to help out [nonamelive on StackOverflow](http://stackoverflow.com/questions/5284516/how-can-i-draw-image-with-text-wrapping-on-ios).</a> I'm working on an advanced iOS book right now, and I'll have a longer writeup there.
<!-- more -->

Once you have your arbitrary paths, you want to break them down into rectangles. I've written some code to do this that assumes a known hight for the text lines. Things get more complicated if you have text that includes different font sizes (you need to do some guessing, then try to layout, and go back and correct things if you were wrong).

The goal of this code is to walk down the path boundary, trying to grow an ever-larger rectangle. If the width or the offset of the boundary changes, then it starts a new rectangle.

    - (CFArrayRef)copyRectangularPathsForPath:(CGPathRef)path 
                                       height:(CGFloat)height {
		CFMutableArrayRef paths = CFArrayCreateMutable(NULL, 0, 
                                                       &kCFTypeArrayCallBacks);

		// First, check if we're a rectangle. If so, we can skip the hard parts.
		CGRect rect;
		if (CGPathIsRect(path, &rect)) {
			CFArrayAppendValue(paths, path);
		}
		else {
			// Build up the boxes one line at a time. If two boxes have the 
            // same width and offset, then merge them.
			CGRect boundingBox = CGPathGetPathBoundingBox(path);
			CGRect frameRect = CGRectZero;
			for (CGFloat y = CGRectGetMaxY(boundingBox) - height; 
                         y > height; y -= height) {
				CGRect lineRect =
                       CGRectMake(CGRectGetMinX(boundingBox), y, 
                                  CGRectGetWidth(boundingBox), height);
				CGContextAddRect(UIGraphicsGetCurrentContext(), lineRect);
				
                // Do the math with full precision so we don't drift, 
                // but do final render on pixel boundaries.
				lineRect = CGRectIntegral(clipRectToPath(lineRect, path));
				CGContextAddRect(UIGraphicsGetCurrentContext(), lineRect);

				if (! CGRectIsEmpty(lineRect)) {
					if (CGRectIsEmpty(frameRect)) {
						frameRect = lineRect;
					}
					else if (frameRect.origin.x == lineRect.origin.x && 
                             frameRect.size.width == lineRect.size.width) {
						frameRect = CGRectMake(lineRect.origin.x,                                                                                       											   lineRect.origin.y,                                                                                         											   lineRect.size.width, 
                                    CGRectGetMaxY(frameRect) - CGRectGetMinY(lineRect));
					}
					else {
						CGMutablePathRef framePath =
                                             CGPathCreateMutable();
						CGPathAddRect(framePath, NULL, frameRect);
						CFArrayAppendValue(paths, framePath);

						CFRelease(framePath);
						frameRect = lineRect;
					}
				}
			}
			
			if (! CGRectIsEmpty(frameRect))	{
				CGMutablePathRef framePath = CGPathCreateMutable();
				CGPathAddRect(framePath, NULL, frameRect);
				CFArrayAppendValue(paths, framePath);
				CFRelease(framePath);
			}			
		}

		return paths;
	}

Remember, the coordinate system here is flipped for iOS. So `CGRectGetMaxY()` is returning the top of the box, not the bottom. The call to `clipRectToPath()` is from my previous post on clipping rectangles to paths. Also noteworthy here is our use of `UIGraphicsGetCurrentContext()`. This routine is meant to be called inside of `drawRect:`.

There are some inefficiencies here. More efficient approaches would calculate the rectangles a single time, rather than during `drawRect:` (though this isn't as inefficient as it sounds, since we try to avoid calling `drawRect:` more than we need). A better implementation could avoid some of the memory churn in `clipRectToPath()` by allocating a single large buffer. But this hopefully is a reasonable example of how to attack the problem.

An example Xcode project is attached.

<a href='http://robnapier.net/blog/wp-content/uploads/2011/03/Columns.zip'>Columns.zip</a>
