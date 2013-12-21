---
layout: post
status: publish
published: true
title: Broader use of ObjC
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: The question was whether Objective-C is only used for development on Mac
  OS/iPhone and why. I think ObjC has been isolated to the Apple world through a quirk
  of history and the nature of proprietary systems.
wordpress_id: 371
wordpress_url: http://robnapier.net/blog/?p=371
date: 2009-08-03 21:37:56.000000000 -04:00
categories:
- cocoa
tags: []
---
<i>Based on a <a href="http://stackoverflow.com/questions/874690/is-objective-c-only-used-for-development-on-mac-os-iphone/874837">post</a> at StackOverflow. The question was whether Objective-C is only used for development on Mac OS/iPhone and why.</i>

I think ObjC has been isolated to the Apple world through a quirk of history and the nature of proprietary systems.
<!-- more -->
First, you need to separate ObjC from Cocoa. ObjC is a very primitive language. I think it is a very elegant language, but it is extremely basic. You can implement ObjCv1 in a C pre-processor. C++ and ObjC were developed about the same time. C++ put a huge amount of infrastructure in place to bring a C-like syntax to what is basically a completely different language. ObjC brought a Smalltalk-like syntax to C, with almost nothing else. Even things like +alloc and -release aren't language elements of ObjC. They're fairly simple wrappers around malloc() and free().<sup><a href="#footnote-1">[*]</a></sup> Standing on its own, ObjC isn't really that interesting (elegant as I think it is). This is very similar to the nature of Smalltalk. Without its object libraries, there isn't much you can do with it. With its object libraries, it's incredibly powerful.

NeXT provided this entire framework on top of ObjC called NeXTSTEP. Since the NeXT computer was not a widespread commercial success, and NeXTSTEP was proprietary, not many people learned the framework or the underlying language. When Apple bought it and morphed it into Cocoa, it continued to be a proprietary system.

GNUStep is out there, but they never developed anything interesting enough to bring in a lot of developers (a major web browser or word processor or the like). And Cocoa has gotten well ahead of GNUStep over the last few years. It's possible that with the rise of interest in Cocoa due to iPhone, GNUStep may finally revitalize and bring a nice cross-platform development framework, but I doubt it. Folks who have a background in C++ look at C# and see a clear improvement. When they look at ObjC, they see a lot of square brackets where they don't expect them. For people raised on the "calling methods" paradigm, the Smalltalk paradigm of "passing messages" is alien and even a bit scary. Many developers assume they need a strongly typed language to avoid bugs and are uncomfortable with a system that relies primarily on programmer discipline and careful consistency. It is much easier to hack something that "just works" in C# than in ObjC. ObjC really expects a lot more of the developer in understanding what's going on and not relying on the compiler to protect you from your hacks.

Basically, folks knew C from Unix, and C++ makes sense in terms of C, and Java makes sense in terms of C++, and C# is just cleaned up Java. ObjC isn't any of these. It's Smalltalk, and no one learns Smalltalk anymore.

<sup><a name="footnote-1">[*]</a></sup> I recently chatted with the guy who wrote +alloc about its history, and he might object to my calling it a simple wrapper given the inclusion of zones. So for you who know the difference, replace +alloc here with +new.
