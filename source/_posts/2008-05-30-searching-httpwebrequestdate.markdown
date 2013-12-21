---
layout: post
status: publish
published: true
title: Searching for HttpWebRequest.Date
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: "A fie on useless attempts to stop hacking... At least that's my current
  assumption on why Microsoft did this. I'm a Cocoa guy, but I actually like .NET
  and hack a bit of it now and then. It's a pretty good framework, though you can
  see some of the seams where Microsoft didn't quite think it through when they were
  designing it and had to tack on later (the whole System.Text.Encoding namespace
  that's made up of methods that should exist on String; but then C# doesn't have
  ObjC-style categories so they probably also being more careful about throwing 10k
  methods on a single class the way Cocoa does, but I'm running off on a tangent here).\r\n\r\nThe
  point today is the headache that is the HttpWebRequest.Date property. What HttpWebRequest.Date
  property you might ask? That's right; there isn't one. "
wordpress_id: 111
wordpress_url: http://robnapier.net/blog/?p=111
date: 2008-05-30 09:39:41.000000000 -04:00
categories:
- .NET
tags:
- Security
- .NET
- Cerberus
---
A fie on useless attempts to stop hacking... At least that's my current assumption on why Microsoft did this. I'm a Cocoa guy, but I actually like .NET and hack a bit of it now and then. It's a pretty good framework, though you can see some of the seams where Microsoft didn't quite think it through when they were designing it and had to tack on later (the whole System.Text.Encoding namespace that's made up of methods that should exist on String; but then C# doesn't have ObjC-style categories so they probably also being more careful about throwing 10k methods on a single class the way Cocoa does, but I'm running off on a tangent here).

The point today is the headache that is the HttpWebRequest.Date property. What HttpWebRequest.Date property you might ask? That's right; there isn't one. <a id="more"></a><a id="more-111"></a>It's a magical protected property that you can neither set nor meaningfully read. The system sets it for you when you make the connection and you can't do anything about it. Why? Most likely because messing with your date is a part of many kinds of attacks on web servers. But maybe they were just too lazy to implement it such that it would be automatically set only if you hadn't automatically set it. I'll assume for now that some misguided hope of improving security guided them on this. But it's a stupid approach.

The work around is to build a raw TcpClient that talks HTTP, which is a pain for legitimate developers, but not so much of a pain that it would barely slow down attackers. It's a pain if you want to talk HTTP correctly, because especially HTTP 1.1 is actually a bit tricky. But if you just want to replay a forged session, then it's not so bad.

But why would you want to screw with your date? For security reasons.... authentication in particular. I don't actually need to change my date; I just need to know what it is *before* I send the POST. When talking to Cerberus Web-API, the HTTP date header is one of the things they hash in their authentication token. That's a pretty good model; provides a decent defense against certain kinds of replay attacks. But it requires that you know exactly what time will be listed in your Date: header. If you guess using Datetime.Now, you can probably build a system that works most of the time. But if the second ticks over between the time you grab it and the time .NET assigns the Date header, you miss and don't authenticate. Classic race condition.

So I'm back to writing a full TcpClient so I can write all my headers, which isn't the end of the world, but is much more fragile and complicated than an HttpWebRequest. I'm going to have to dig into whether HTTP 1.0 will allow a Date header when talking to IIS. If it does (and it probably does because headers outside the standard are generally legal), then at least that will simplify things and I don't have to worry about GetChunked or any of the other little things you need to do to be a proper 1.1 client. As long as 1.0 will also work with virtual hosts and the Host header.... It's always something.
