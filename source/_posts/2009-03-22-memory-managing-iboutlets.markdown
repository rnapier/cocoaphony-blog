---
layout: post
status: publish
published: true
title: Memory Managing IBOutlets
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
wordpress_id: 17
wordpress_url: http://cocoaphony.wordpress.com/?p=17
date: 2009-03-22 13:29:22.000000000 -04:00
categories:
- cocoa
tags:
- cocoa
- memory management
- Interface Builder
---
Apple <em>finally </em>updated the <a href="http://developer.apple.com/documentation/Cocoa/Conceptual/MemoryMgmt/Articles/mmNibObjects.html">Memory Management Guide</a> to deal with IBOutlets.

They came to the same recommendation that many of us have. Treat them exactly like other properties. Mark them as retain properties, release them in -dealloc, and overload -setView to clear them in low-memory situations. This last recommendation was one that many of us used, but was based on undocumented behaviors. Apple finally documented the behavior because there's no other good way to do it given their internal implementation.

Unfortunately they haven't updated the "Using View Controllers" documentation to include this stuff, and the section on how -loadView works is still a bit vague. I've sent them feedback on those pages.
