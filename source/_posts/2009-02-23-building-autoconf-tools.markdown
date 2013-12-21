---
layout: post
status: publish
published: true
title: Building autoconf tools
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
wordpress_id: 66
wordpress_url: http://robnapier.net/blog/?p=66
date: 2009-02-23 09:16:19.000000000 -05:00
categories:
- builds
tags:
- autoconf
- builds
- xcode
---
Trying to solve this problem last night, I came across this great script to automate the process. Works great, right out of the box.

<a href="http://pseudogreen.org/blog/build_autoconfed_libs_for_iphone.html">build_for_iphoneos</a>

If you want to integrate this with an xcodebuild, you'll still need to build a small xcodeproj file. There's a template for this and instructions here:

<a href="http://developer.apple.com/DOCUMENTATION/Porting/Conceptual/PortingUnix/preparing/preparing.html#//apple_ref/doc/uid/TP40002849-BBCJABGC">Building Makefile Projects With XCode</a>
