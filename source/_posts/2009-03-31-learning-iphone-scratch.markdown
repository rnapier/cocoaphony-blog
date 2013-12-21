---
layout: post
status: publish
published: true
title: Learning iPhone from scratch
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: "I'll talk more about it later, but the absolute best way to learn iPhone
  is to learn Mac first. That's how I teach my classes. The available Mac educational
  resources are just much better, at least today.\r\n\r\nThe absolute gold standard
  for learning Cocoa on Mac is <a href=\"http://www.amazon.com/gp/product/0321503619?ie=UTF8&tag=cocoaphony-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0321503619\">Cocoa
  Programming for Mac OS X</a><img src=\"http://www.assoc-amazon.com/e/ir?t=cocoaphony-20&l=as2&o=1&a=0321503619\"
  width=\"1\" height=\"1\" border=\"0\" alt=\"\" style=\"border:none !important; margin:0px
  !important;\" />\r\n by Aaron Hillegass. It is *the* book. I have a syllabus based
  on it that's stripped down to the chapters that are useful for iPhone programmers.
  I'll get that into a blog post.\r\n\r\nWhen I teach this, it runs between 5 and
  10 full days depending on how in-depth I cover the Mac side."
wordpress_id: 134
wordpress_url: http://robnapier.net/blog/?p=134
date: 2009-03-31 20:15:57.000000000 -04:00
categories:
- iphone
tags:
- objective-c
- iphone
---
I'll talk more about it later, but the absolute best way to learn iPhone is to learn Mac first. That's how I teach my classes. The available Mac educational resources are just much better, at least today.

The absolute gold standard for learning Cocoa on Mac is <a href="http://www.amazon.com/gp/product/0321503619?ie=UTF8&tag=cocoaphony-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0321503619">Cocoa Programming for Mac OS X</a><img src="http://www.assoc-amazon.com/e/ir?t=cocoaphony-20&l=as2&o=1&a=0321503619" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />
 by Aaron Hillegass. It is *the* book. I have a syllabus based on it that's stripped down to the chapters that are useful for iPhone programmers. I'll get that into a blog post.

When I teach this, it runs between 5 and 10 full days depending on how in-depth I cover the Mac side.<!-- more -->

ObjC follows the Smalltalk paradigm of highly dynamic, loose typing. In that way it is more like Perl w/ strict than like Java (even more like Perl than like C in some ways). It has very limited inheritance (and nothing like protected methods for instance). It has none of the safety concepts of Caml (or even C++). There is a great number of things that cannot be determined until runtime in ObjC. Like Perl-OOP, ObjC OOP is somewhat syntactic sugar sprinkled over an existing language, and so much of the rule-enforcement is left to the programmer.

Thus convention is the only thing protecting you from programming error. The compiler can do very little to protect you. Luckily, Cocoa provides an ObjC framework that has extremely consistent convention, and if you follow it carefully, you will consistently avoid errors in practice that seem unavoidable in theory.

You can learn the entire ObjC language in an hour. It's very, very simple (ObjC v1 can be and has been implemented as a simple macro processor that converts ObjC to C). It's Cocoa conventions that take more time, experience and right-thinking to learn. Most bad ObjC programmers know the language, but do not understand the patterns that are so important to Cocoa development. There are many things that are legal in Cocoa, but there are certain ways things are done, and certain ways they are not.

And of course the other major source of information is developer.apple.com and the SDK documentation, especially the conceptual documents. People skip over these, thinking they can just jump into "what do I call to make this happen." Then they chase memory problems all day and can't figure out why.
