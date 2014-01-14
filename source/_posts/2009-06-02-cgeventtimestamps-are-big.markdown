---
layout: post
status: publish
published: true
title: CGEventTimestamps are big
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: An event timestamp is a big, unsigned, 64-bit number. That's big, really
  big. You just won't believe how vastly, hugely, mind-bogglingly big it is. You may
  think your application has been running for a long time, but that's just peanuts
  to an event timestamp
wordpress_id: 383
wordpress_url: http://robnapier.net/blog/?p=383
date: 2009-06-02 17:45:47.000000000 -04:00
categories:
- cocoa
tags: []
---
I can't take credit for finding this myself. Gilad Gurantz forwarded it to me. From the Quartz Event Services documentation:

<blockquote><p><b>CGEventTimestamp</b></p>
Defines the elapsed time in nanoseconds since startup that a Quartz event occurred.

<code>typedef uint64_t CGEventTimestamp;</code>

<b>Discussion</b>
An event timestamp is a big, unsigned, 64-bit number. That's big, really big. You just won't believe how vastly, hugely, mind-bogglingly big it is. You may think your application has been running for a long time, but that's just peanuts to an event timestamp.</blockquote>

So if my math is right, "a long time" translates into over 2850 years. And it's counted since the last reboot. I think we'll avoid the Y2K problem on this one.
