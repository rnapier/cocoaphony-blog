---
layout: post
status: publish
published: true
title: GCD + iPhone
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: 'I''ve said that multi-core would come to mobile devices because everything
  will come to mobile devices. And for the iPhone, multi-core also makes a lot of
  sense by allowing Apple to dedicate a core to its own use during important functions
  like phone calls. But Carl Howe makes an even more compelling argument for mobile
  multi-core: better battery life.'
wordpress_id: 441
wordpress_url: http://robnapier.net/blog/?p=441
date: 2009-09-14 09:14:51.000000000 -04:00
categories:
- iphone
tags: []
---
[The long-lasting power of Snow Leopard](http://blogs.yankeegroup.com/2009/08/26/the-long-lasting-power-of-snow-leopard/) from The Yankee Group.

Ever since I first saw GCD at WWDC, I've been amazed by it and eager to give it a real spin. But since the vast majority of my work is in low-level libraries that run on both Mac and iPhone, GCD is closed to me (as is garbage collection; more on that later). I've said that multi-core would come to mobile devices because everything will come to mobile devices (laptops are the new desktops, and mobile is the new laptop). And for the iPhone, multi-core also makes a lot of sense by allowing Apple to dedicate a core to its own use during important functions like phone calls. But Carl Howe makes an even more compelling argument for mobile multi-core: better battery life.

With multi-core comes another strong possibility: garbage collection. The availability of a second core makes this more likely on iPhone. Yes, memory is tighter, but ever-growing. And GC will likely do a better job of reclaiming memory faster than much of the leaky programs I see from novice programmers. But to do it well, I think a second core is a real must. I've grown good at memory management over the years, and it's hard for me to write GC Cocoa because it "feels wrong." But I think I could get used to it.... And it would help alleviate the biggest class of coding error I see in Cocoa programs.

Of course, the clang static analyzer will probably help get rid of 90% of those errors anyway, so maybe the need for GC just went way down.... Have I mentioned recently how incredible clang really is? I desperately long for them to finish bringing it to Obj-C++ so I can use it.
