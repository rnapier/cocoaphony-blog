---
layout: post
status: publish
published: true
title: Importing UIKit vs. Cocoa
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: 'There''s almost never a reason to #ifdef importing UIKit or Cocoa. If you
  are, you should probably just be importing Foundation. But what of NSImage and UIImage?
  There''s an easy fix for that.'
wordpress_id: 436
wordpress_url: http://robnapier.net/blog/?p=436
date: 2009-08-20 11:28:40.000000000 -04:00
categories:
- cocoa
- iphone
tags: []
---
I work on a lot of projects that share significant code between iPhone and Mac versions. This is the beauty of Cocoa. While working on these projects, I've bumped into this idiom many times:

    #ifdef TARGET_OS_IPHONE
    #import <UIKit/UIKit.h>
    #else
    #import <Cocoa/Cocoa.h>
    #endif

This is almost never correct, and almost always means that someone imported Cocoa.h into a model class. Model classes should never rely on UIKit or Cocoa. They should just import Foundation.h.

There is one interesting exception that we've run into: NSImage versus UIImage. These are really model classes, but they're part of AppKit and UIKit. They have very similar interfaces, so in most code you should be able to interchange them and keep everything portable. What to do?
<!-- more -->

    #ifdef TARGET_OS_IPHONE
    #import <UIKit/UIImage.h>
    typedef UIImage XXImage;
    #else
    #import <AppKit/NSImage.h>
    typedef NSImage XXImage;
    #endif

You can now import XXimage.h into your model classes and use XXImage anywhere you would normally use NSImage or UIImage (as long as you're using them in a portable way). In your UI (platform) code, you can still use NSImage or UIImage normally; no need to use XXImage everywhere, since the types are compatible.

Or you could go to CGImages exclusively, but what a pain if you don't need them already.

<b>EDIT Sep 24, 2009:</b> In light of a Radar I've recently opened (radar://7224053), I need to amend the above. It's better to use #define rather than typedef. I strongly prefer typedef, but there's a bizarre bug that it bumps into. Typedef confuses `valueForKey:` for some reason. You can use the following code to determine if the bug has been fixed yet:

~~~~
#import <Foundation/Foundation.h>
// Swapping #define for typedef makes this work
typedef NSString MYString;
//#define MYString NSString
@interface MYObject : NSObject {}
- (MYString *)string;
@end
@implementation MYObject
- (MYString *)string {
    return @"a string";
}
@end
int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    MYObject *object = [[[MYObject alloc] init] autorelease];
    MYString *string = [object valueForKey:@"string"];  // Fails w/ "not KVC-compliant for key string"
//    MYString *string = [object string];   // Works
    NSLog(@"image = %@", string);
    [pool drain];
    return 0;
}
~~~~
