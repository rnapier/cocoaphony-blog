---
layout: post
status: publish
published: true
title: Garbage collection
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: "Two posts in a day... but this was a completely different topic.\r\n\r\nI'm
  beginning work on my first Leopard-only application, and so I'm trying out garbage
  collection. Sure, I'm excited about garbage collection. Sure, I have no great love
  of keeping track of my retain counts and autorelease pools. But....\r\n\r\nIt feels
  really, really weird to not release my variables. I tend to rely on autorelease
  a lot. I know there are some disadvantages, but I like the fact that it notes your
  intention when you allocate the memory. "
wordpress_id: 100
wordpress_url: http://robnapier.net/blog/?p=100
date: 2008-03-08 11:23:22.000000000 -05:00
categories:
- cocoa
tags:
- cocoa
- memory management
- Leopard
- Garbage Collection
---
Two posts in a day... but this was a completely different topic.

I'm beginning work on my first Leopard-only application, and so I'm trying out garbage collection. Sure, I'm excited about garbage collection. Sure, I have no great love of keeping track of my retain counts and autorelease pools. But....

It feels really, really weird to not release my variables. I tend to rely on autorelease a lot. I know there are some disadvantages, but I like the fact that it notes your intention when you allocate the memory. <!-- more --> Consider this:
<pre lang="objc">NSMenuItem *mi = [[[NSMenuItem alloc] initWithTitle:@"" action:NULL keyEquivalent:@""] autorelease];
[menu addItem:mi];</pre>
versus
<pre lang="objc">NSMenuItem *mi = [[NSMenuItem alloc] initWithTitle:@"" action:NULL keyEquivalent:@""];
[menu addItem:mi];
[mi release];</pre>
It's not the extra line of code that bothers me. It's the fact that the release is separated, such that if you move the assignment of mi into another method, you have to remember to move the release as well (and and that point, you'd *have* to switch to autorelease). Remember that there can be a lot more code between the alloc and the addItem. This makes the Extract Method refactor more complicated. autorelease makes this easy, and at very small cost. Beyond that, it emphasizes at the init that I won't be holding onto this memory myself. Of course that's also implied by the use of a temporary variable, but the point remains. It also helps me find memory leaks more easily. Since I always do it this way, I know that if I've used alloc on a local variable with no autorelease, I've almost certainly got a bug.

Of course the point of this posting is that my long-developed opinions on this matter are now irrelevant. You just assign mi any old way you like and it'll get garbage collected when appropriate. Great. Easy. Who could not love that?

But I am having a very hard time getting used to not having an autorelease at the end of that initialization. There's an alloc on a local variable with no autorelease. Bug! It's hard for me even to type it; I always lead with three open brackets....

I'll get over it.
