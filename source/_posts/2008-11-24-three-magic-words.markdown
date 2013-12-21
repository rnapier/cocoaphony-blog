---
layout: post
status: publish
published: true
title: Three Magic Words
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: "Here are the three magic words: +alloc, -copy and +new. If you commit these
  magic words to memory, and devote yourself to a life of accessors, then Cocoa memory
  management should cause you no fear.\r\n\r\nFor those interested in the path to
  memory management enlightenment, you should first deeply understand every word of
  the <a href=\"http://developer.apple.com/documentation/Cocoa/Conceptual/MemoryMgmt/Articles/mmRules.html\"
  target=\"_blank\">Memory Management Rules</a>. Don't be afraid, it is very short,
  and if you will commit it to heart, you will avoid much suffering in the future. "
wordpress_id: 6
wordpress_url: http://cocoaphony.wordpress.com/2009/04/19/three-magic-words/
date: 2008-11-24 17:55:31.000000000 -05:00
categories:
- cocoa
tags:
- cocoa
- memory management
---
Here are the three magic words: +alloc, -copy and +new. If you commit these magic words to memory, and devote yourself to a life of accessors, then Cocoa memory management should cause you no fear.

For those interested in the path to memory management enlightenment, you should first deeply understand every word of the <a href="http://developer.apple.com/documentation/Cocoa/Conceptual/MemoryMgmt/Articles/mmRules.html" target="_blank">Memory Management Rules</a>. Don't be afraid, it is very short, and if you will commit it to heart, you will avoid much suffering in the future. <!-- more -->

Cocoa memory management is very simple and very consistent:
<blockquote>You take ownership of an object if you create it using a method whose name begins with "alloc" or "new" or contains "copy" (for example, <code><a href="http://developer.apple.com/documentation/Cocoa/Reference/Foundation/Classes/NSObject_Class/Reference/Reference.html#//apple_ref/occ/clm/NSObject/alloc" target="_blank">alloc</a></code>, <code><a href="http://developer.apple.com/documentation/Cocoa/Reference/ApplicationKit/Classes/NSObjectController_Class/Reference/Reference.html#//apple_ref/occ/instm/NSObjectController/newObject" target="_blank">newObject</a></code>, or <code><a href="http://developer.apple.com/documentation/Cocoa/Reference/Foundation/Classes/NSObject_Class/Reference/Reference.html#//apple_ref/occ/instm/NSObject/mutableCopy" target="_blank">mutableCopy</a></code>), or if you send it a <code>retain</code>message. You are responsible for relinquishing ownership of objects you own using <code><a href="http://developer.apple.com/documentation/Cocoa/Reference/Foundation/Protocols/NSObject_Protocol/Reference/NSObject.html#//apple_ref/occ/intfm/NSObject/release" target="_blank">release</a></code> or<code><a href="http://developer.apple.com/documentation/Cocoa/Reference/Foundation/Protocols/NSObject_Protocol/Reference/NSObject.html#//apple_ref/occ/intfm/NSObject/autorelease" target="_blank">autorelease</a></code>. Any other time you receive an object, you must <em>not</em> release it.</blockquote>
That's the entirety of non-garbage-collected Cocoa memory management, the rest is, as they say, just commentary. If I were to add one more rule that will save you much heartache, it is this:
<blockquote>Retain things you care about for longer than this event loop. Release things when you stop caring about them.</blockquote>
Much trouble occurs in Cocoa programs when programmers violate this rule. When they think "I know such-and-such is retaining it for me, so I don't need to retain it," crashes follow. There is even some Apple sample code that does this (the NSURLConnection examples in particular), and I think it's a mistake.
