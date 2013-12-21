---
layout: post
status: publish
published: true
title: Laying out text with Core Text
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: 'Today''s question is about laying out text without CTFramesetter. We''re
  going to take a whirlwind tour through some CoreText code to demonstrate this. '
wordpress_id: 547
wordpress_url: http://robnapier.net/blog/?p=547
date: 2011-05-20 11:09:12.000000000 -04:00
categories:
- cocoa
- iphone
tags: []
---
I'm back in full book-writing mode, now working with <a href="http://mugunthkumar.com/">Mugunth Kumar</a>, who is brilliant. Go check out his stuff. Hopefully we'll have something published and in all your hands by the end of the year. The book has taken up most of my writing time, so the blog will continue to be a bit quiet, but sometimes I like to answer a Stackoverflow question a bit more fully than I can there.

Today's question is about <a href="http://stackoverflow.com/questions/6062420/core-text-performance/6062816#6062816">laying out text without `CTFramesetter`</a>. We're going to take a whirlwind tour through some CoreText code to demonstrate this. It's not quite what the OP was asking about, but it shows some techniques and I had it handy. I'll be writing a whole chapter on Core Text soon.

The goal of this project was to make "pinch" view. It lays out text in a view, and where ever you touch, the text is pinched towards that point. It's not meant to be really useful. Everything is done in `drawRect:`, which is ok in this case, since we only draw when we're dirty, and when we're dirty we have to redraw everything anyway. But in many cases, you'd want to do these calculations elsewhere, and only do final drawing in `drawRect:`.

We start with some basic view layout, and loop until we run out of text or run out of vertical space in the view.
<!-- more -->

    - (void)drawRect:(CGRect)rect {      
      [... Basic view setup and drawing the border ...]
      
      // Work out the geometry
      CGRect insetBounds = CGRectInset([self bounds], 40.0, 40.0);
      CGPoint textPosition = CGPointMake(floor(CGRectGetMinX(insetBounds)),
                                         floor(CGRectGetMaxY(insetBounds)));
      CGFloat boundsWidth = CGRectGetWidth(insetBounds);

      // Calculate the lines
      CFIndex start = 0;
      NSUInteger length = CFAttributedStringGetLength(attributedString);
      while (start < length && textPosition.y > insetBounds.origin.y)
      {

Now we ask the typesetter to break off a line for us.

        CTTypesetterRef typesetter = self.typesetter;
        CFIndex count = CTTypesetterSuggestLineBreak(typesetter, start, boundsWidth);
        CTLineRef line = CTTypesetterCreateLine(typesetter, CFRangeMake(start, count));

And decide whether to full-justify it or not based on whether it's at least 85% of a line:

        CGFloat ascent;
        CGFloat descent;
        CGFloat leading;
        double lineWidth = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        
        // Full-justify if the text isn't too short.
        if ((lineWidth / boundsWidth) > 0.85)
        {
          CTLineRef justifiedLine = CTLineCreateJustifiedLine(line, 1.0, boundsWidth);
          CFRelease(line);
          line = justifiedLine;
        }
        
Now we start pulling off one `CTRun` at a time. A run is a series of glyphs within a line that share the same formatting. In our case, we should generally just have one run per line. This is a good point to explain the difference between a glyph and character. A character represents a unit of information. A glyph represents a unit of drawing. In the vast majority of cases in English, these two are identical, but there a few exceptions even in English called ligatures. The most famous is "fi" which in some fonts is drawn as a single glyph. Open TextEdit. Choose Lucida Grande 36 point font. Type "fi" and see for yourself how it's drawn. Compare it to "ft" if you think it's just drawing the "f" too wide. The joining is on purpose.

So the thing to keep in mind is that there can be a different number of glyphs than characters. High-level Core Text objects work in characters. Low-level objects work in glyphs. There are functions to convert character indexes into glyph indexes and vice versa. So, let's back to the code. We're going to move the Core Graphics text pointer and start looping through our `CTRun` objects:

        // Move us forward to the baseline
        textPosition.y -= ceil(ascent);
        CGContextSetTextPosition(context, textPosition.x, textPosition.y);
        
        // Get the CTRun list
        CFArrayRef glyphRuns = CTLineGetGlyphRuns(line);
        CFIndex runCount = CFArrayGetCount(glyphRuns);
        
        // Saving for later in case we need to use the actual transform. It's faster
        // to just add the translate (see below).
        //		CGAffineTransform textTransform = CGContextGetTextMatrix(context);
        //		CGAffineTransform inverseTextTransform = CGAffineTransformInvert(textTransform);
        
        for (CFIndex runIndex = 0; runIndex < runCount; ++runIndex)
        {


Now we have our run, and we're going to work out the font so we can draw it. By definition, the entire run will have the same font and other attributes. Note that the code only handles font changes. It won't handle decorations like underline (remember: bold is a font, underline is a decoration). You'd need to add more code if you wanted that.


          CTRunRef run = CFArrayGetValueAtIndex(glyphRuns, runIndex);
          CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run),
                                                   kCTFontAttributeName);

          // FIXME: We could optimize this by caching fonts we know we use.
          CGFontRef cgFont = CTFontCopyGraphicsFont(runFont, NULL);
          CGContextSetFont(context, cgFont);
          CGContextSetFontSize(context, CTFontGetSize(runFont));
          CFRelease(cgFont);

Now we're going to pull out all the glyphs so we can lay them out one at a time. `CTRun` has one of those annoying `Get...Ptr` constructs that are common in Core frameworks. `CTRunGetPositionsPtr()` will very quickly return you the internal pointer to the glyphs locations. But it might fail if the `CTRun` hasn't calculating them yet. If that happens, then you have to call `CTRunGetPositions()` and hand it a buffer to copy into. To handle this, I keep around a buffer that I `realloc()` to the largest size I need. This almost never comes up because `CTRunGetPositionsPtr()` almost always returns a result.

Note the comment about being "slightly dangerous." I'm grabbing the internal location data structures and modifying them. This works out because we are the only user of this `CTRun`, but these are really immutable structures. If two `CTRun` objects are created from the same data, then Apple is free to return us two pointers to the same object. So it's within the specs that we're actually modifying data that some other part of the program is using for a different layout. That's pretty unlikely, but it's worth keeping in mind. My early tests of this on a first-generation iPad suggested that this optimization was noticeable in Instruments. On the other hand, I hadn't applied some other optimizations yet (like reusing `positionsBuffer`), so it may be practical to get better safety and performance here. I'll have to profile further.
          
          CFIndex glyphCount = CTRunGetGlyphCount(run);
          
          // This is slightly dangerous. We're getting a pointer to the internal
          // data, and yes, we're modifying it. But it avoids copying the memory
          // in most cases, which can get expensive.
          CGPoint *positions = (CGPoint*)CTRunGetPositionsPtr(run);
          if (positions == NULL)
          {
            size_t positionsBufferSize = sizeof(CGPoint) * glyphCount;
            if (malloc_size(positionsBuffer) < positionsBufferSize)
            {
              positionsBuffer = realloc(positionsBuffer, positionsBufferSize);
            }
            CTRunGetPositions(run, kRangeZero, positionsBuffer);
            positions = positionsBuffer;
          }
          
          // This one is less dangerous since we don't modify it, and we keep the const
          // to remind ourselves that it's not to be modified lightly.
          const CGGlyph *glyphs = CTRunGetGlyphsPtr(run);
          if (glyphs == NULL)
          {
            size_t glyphsBufferSize = sizeof(CGGlyph) * glyphCount;
            if (malloc_size(glyphsBuffer) < glyphsBufferSize)
            {
              glyphsBuffer = realloc(glyphsBuffer, glyphsBufferSize);
            }
            CTRunGetGlyphs(run, kRangeZero, (CGGlyph*)glyphs);
            glyphs = glyphsBuffer;
          }
          
Now we move around the characters with a little trig. I originally coded this using `CGAffineTransforms`, but doing the math by hand turned out to be much faster.

          // Squeeze the text towards the touch-point
          if (touchIsActive)
          {
            for (CFIndex glyphIndex = 0; glyphIndex < glyphCount; ++glyphIndex)
            {
              // Text space -> user space
              // Saving the transform in case we ever want it, but just applying
              // the translation by hand is faster.
              // CGPoint viewPosition = CGPointApplyAffineTransform(positions[glyphIndex], textTransform);
              CGPoint viewPosition = positions[glyphIndex];
              viewPosition.x += textPosition.x;
              viewPosition.y += textPosition.y;
              
              CGFloat r = sqrtf(hypotf(viewPosition.x - touchPoint.x,
                                       viewPosition.y - touchPoint.y)) / 4;
              CGFloat theta = atan2f(viewPosition.y - touchPoint.y, 
                                     viewPosition.x - touchPoint.x);
              CGFloat g = 10;
              
              viewPosition.x -= floorf(cosf(theta) * r * g);
              viewPosition.y -= floor(sinf(theta) * r * g);
              
              // User space -> text space
              // Note that this is modifying an internal data structure of the CTRun.
              // positions[glyphIndex] = CGPointApplyAffineTransform(viewPosition, inverseTextTransform);
              viewPosition.x -= textPosition.x;
              viewPosition.y -= textPosition.y;
              positions[glyphIndex] = viewPosition;
            }
          }

Finally, finally, we draw the glyphs and move down a line. We move down by adding the previous-calculated descent, leading and then +1. The "+1" was added because it matches up with how CTFramesetter lays out. Otherwise the descenders of one line exactly touch the ascenders of the next line.

          CGContextShowGlyphsAtPositions(context, glyphs, positions, glyphCount);
        }
        
        // Move the index beyond the line break.
        start += count;
        textPosition.y -= ceilf(descent + leading + 1); // +1 matches best to CTFramesetter's behavior	
        CFRelease(line);
      }
      free(positionsBuffer);
      free(glyphsBuffer);
    }

So there you have it. It's a whirlwind tour showing how to lay glyphs out one-by-one. Attached is an example project showing it in real life.

<a href='http://robnapier.net/blog/wp-content/uploads/2011/05/TextDemo.zip'>TextDemo</a>
