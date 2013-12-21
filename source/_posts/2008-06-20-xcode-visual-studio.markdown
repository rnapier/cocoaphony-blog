---
layout: post
status: publish
published: true
title: XCode vs. Visual Studio
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: "I move between Visual Studio and XCode a bit without shuddering or fussing,
  which seems to make me a strange creature. In general, shocking as it is to say
  on a Cocoa list, VS is actually a much more powerful environment. Most who love
  XCode have little used VS (at least VS2005 or later, VS.NET is clunky IMO). But
  learning what actually is better about VS requires using XCode for quite some time.
  Most of the initial complaints are simply small differences between the two; many
  of which I prefer the XCode way. But then, XCode is a Mac app, and I generally prefer
  Mac UI.\r\n"
wordpress_id: 114
wordpress_url: http://robnapier.net/blog/?p=114
date: 2008-06-20 10:50:24.000000000 -04:00
categories:
- cocoa
- .NET
tags:
- cocoa
- xcode
- .NET
- Visual Studio
---
I move between VS and XCode a bit without shuddering or fussing, which seems to make me a strange creature. In general, shocking as it is to say on a Cocoa list, VS is actually a much more powerful environment. Most who love XCode have little used VS (at least VS2005 or later, <a href="http://vs.net/" target="_blank">VS.NET</a> is clunky IMO). But learning what actually is better about VS requires using XCode for quite some time. Most of the initial complaints are simply small differences between the two; many of which I prefer the XCode way. But then, XCode is a Mac app, and I generally prefer Mac UI.

<a id="more"></a><a id="more-114"></a>As a regular user of both, here are some advantages of VS that do not wear off when you get used to XCode:
<ul>
	<li>Much deeper integration with its debugger. XCode and gdb play together, but they're not integrated the way VS is with its debugger. There are many important gdb features that can't easily be reached from XCode, and some (debugging with a core file) that you pretty much can't run XCode at all if you want to accomplish.</li>
	<li>The multi-tab interface makes it much easier to manage moving between many files, and the debugger is better integrated with the editor. XCode encourages you to have an explosion of windows, and the debugger is inconsistently integrated with the editor. The AllInOne interface for XCode goes too far the other way and makes moving between files a real pain.</li>
	<li>Mouse-over gives much better information in VS when editing. VS is always compiling your code, and so can give you access to information in the editor that is only available in the debugger for XCode. XCode technically also is always compiling your code (or it claims to), but it doesn't really make use of this fact.</li>
	<li>VS is better in nearly every conceivable way if you're programming in C++. XCode hates C++. If you use wstrings in C++, XCode will actually come out of the computer and slap you around (who knows, maybe it should). I dream of being able to easily display wstrings in the debugger. Yes, I've built the formatting plugins and from time to time they even work. Probably the biggest missing feature in XCode is good code completion for C++, especially with overloads, which VS does very well.</li>
</ul>
All that said, I still much prefer to work in XCode, but mostly because I prefer coding in Cocoa to .NET (.NET is actually pretty nice, but Cocoa is nicer). Apple's help documentation for Cocoa is far superior to Microsoft's documentation for .NET (which is infuriating to work with), and getting to the help in XCode is much more effective than in VS.

So to VS guys I say: Give XCode a chance. It's better than you think once you are used to Mac interfaces and if you're working on Cocoa apps (which XCode is highly optimized for). To XCode guys I say: until you've used VS for a while, don't assume that XCode has all the features it should. In the programming editor world, XCode is still kind of primitive.
