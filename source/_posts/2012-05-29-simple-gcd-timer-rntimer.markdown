---
layout: post
status: publish
published: true
title: Simple GCD Timer (RNTimer)
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: You would think it would be easy to have a repeating timer that didn't create
  a retain loop. I offer RNTimer as a simple solution to this common problem.
wordpress_id: 762
wordpress_url: http://robnapier.net/blog/?p=762
date: 2012-05-29 21:37:25.000000000 -04:00
categories:
- cocoa
- iphone
tags: []
---
<i>I know this exists out there somewhere already, but I couldn't find it anywhere and I was sick of writing it over and over again.... If someone knows of previous art, please point me in the right direction. I know <a href="http://www.fieryrobot.com/blog/2010/07/10/a-watchdog-timer-in-gcd/" target="_blank">Fiery Robot's</a> and <a href="http://www.mikeash.com/pyblog/friday-qa-2010-07-02-background-timers.html" target="_blank">Mike Ash's</a>, but they solve different problems.</i>

Have you ever noticed how hard it is to write a repeating `NSTimer` that doesn't create a retain loop? Almost always you wind up with something like this:

    [NSTimer scheduledTimerWithTimeInterval:1
                                     target:self
                                   selector:@selector(something)
                                   userInfo:nil 
                                    repeats:YES];

Seems easy enough, except it's a retain loop. <a href="http://www.mikeash.com/pyblog/friday-qa-2010-04-30-dealing-with-retain-cycles.html" target="_blank">Mike Ash does a nice job of explaining it</a> and walking you through the hoops you need to avoid it. For such a common thing, you'd think this would be easy. And it should be, so I fixed it. I just still can't quite believe I'm the first to do so.

Anyway, for your consideration I present a very simple class called `RNTimer`. Right now it just handles the most common case: a repeating timer that does not generate a retain loop and automatically invalidates when it is released. It could of course be expanded to handle more NSTimer functionality if there is interest. Let me know if you have a use case that the current implementation doesn't address.

You may find it along with further information at <a href="https://github.com/rnapier/RNTimer" target="_blank">GitHub</a>.
