---
layout: post
status: publish
published: true
title: Re-growling song in PB
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
wordpress_id: 433
wordpress_url: http://robnapier.net/blog/?p=433
date: 2009-08-19 09:01:02.000000000 -04:00
categories:
- PandoraBoy
tags: []
---
I started implementing a hotkey to regrowl the current song. ishermandom sent me a patch months ago to do this, and I've just started integrating it. It's very small, I just hadn't done it yet. Since I've restructured hotkeys due to the ShortcutRecorder upgrade, I've actually had to reimplement it anyway, but really, it's not complicated.

I also pulled some of the NSLog() statements out, so PB will no longer fill your Console with messages about what song is playing. If you want need this functionality for something, let me know. There are better ways for me to implement it.

Funny, Pandora seems down this morning? The silence is deafening. Even while I'm investigating why the flash player isn't coming up (even in Safari), I keep hitting my "play" shortcut because its too quiet. I guess I pull out iTunes....
