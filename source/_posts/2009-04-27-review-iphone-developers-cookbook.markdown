---
layout: post
status: publish
published: true
title: Review of <i>iPhone Developer's Cookbook</i>
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: "<em>Summary: If you want a real understanding of Cocoa and Cocoa Touch,
  this book is too recipe-based to give you that. If you really want recipes, consider
  Apple's <a href=\"http://developer.apple.com/iphone/library/navigation/SampleCode.html\">Sample
  Code</a>.\r\n</em>\r\n\r\nI haven't been thrilled with the first crop of iPhone
  development books that hit the market. This shouldn't be surprising. It's a new
  platform and, as with the first AppStore apps, the pressure to be first to market
  fights the authors' desire to provide the best possible product.\r\n\r\nI was specifically
  asked about <a href=\"http://www.amazon.com/gp/product/0321555457?ie=UTF8&tag=cocoaphony-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0321555457\"
  rel=\"nofollow\">iPhone Developer's Cookbook: Building Applications with the iPhone
  SDK</a> by Erica Sadun. My biggest concern is that it's a cookbook based on \"recipes\"
  to do this or that. This is often exactly the problem with how people learn Mac
  and iPhone development. They think that it's just Java or C++ with a different syntax
  and if they learn where the brackets go, then they'll be a Cocoa developer. "
wordpress_id: 260
wordpress_url: http://robnapier.net/blog/?p=260
date: 2009-04-27 10:17:47.000000000 -04:00
categories:
- iphone
tags:
- cocoa
- iphone
- Learning Cocoa
- cocoa touch
- Learning iPhone
- reviews
---
<em>Summary: If you want a real understanding of Cocoa and Cocoa Touch, this book is too recipe-based to give you that. If you really want recipes, consider Apple's <a href="http://developer.apple.com/iphone/library/navigation/SampleCode.html">Sample Code</a>.
</em>

I haven't been thrilled with the first crop of iPhone development books that hit the market. This shouldn't be surprising. It's a new platform and, as with the first AppStore apps, the pressure to be first to market fights the authors' desire to provide the best possible product.

I was specifically asked about <a href="http://www.amazon.com/gp/product/0321555457?ie=UTF8&tag=cocoaphony-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0321555457" rel="nofollow">iPhone Developer's Cookbook: Building Applications with the iPhone SDK</a> by Erica Sadun. My biggest concern is that it's a cookbook based on "recipes" to do this or that. This is often exactly the problem with how people learn Mac and iPhone development. They think that it's just Java or C++ with a different syntax and if they learn where the brackets go, then they'll be a Cocoa developer. <a id="more"></a><a id="more-260"></a>

As <em>Cookbook</em> describes itself:

<blockquote>This book is written for new iPhone developers with projects to get done and a new unfamiliar SDK in their hands. Although each programmer brings different goals and experiences to the table, most developers end up solving similar tasks in their development work: "How do I build a table?"; "How do I create a secure keychain entry?"; "How do I search the Address Book?"; "How do I move between views?"; and "How do I use Core Location?"</blockquote>

What's missing are questions like "What are the key patterns for this platform?"; "How is memory management and object ownership handled?"; "What functions are generally provided by the framework, and what must I generally code?" Each of these questions has a very different answer in Cocoa than in Java, and each has caused my students (especially those with a Java background) a lot of confusion.

Good Cocoa is much more than the Objective-C syntax and a bunch of AWT-style widgets you need to learn.<sup><a href="#footnote-1">[1]</a></sup> It's really a set of patterns. If you know the patterns, then the widgets will be obvious. If you only know the widgets, then you will tend to be very confused about why it's "so hard" (because you don't know how Cocoa thinks about the problem), and you'll tend to write the kind of junk code that so dominates the AppStore.

At this point, I should emphasize that much of my objection is philosophical and pedagogical in nature. As the book notes, it "is written for new iPhone developers with projects to get done and a new unfamiliar SDK in their hands." If you're facing a tight deadline to get "something out" and you just want something that runs right now, this book pulls several useful problem sets into one place.<sup><a href="#footnote-2">[2]</a></sup>

The second recipe, "Dragging Views" (p45), is a good example. When I teach, concepts like multi-touch are very late in the course. <em>Cookbook</em> dives into UIView, UITouch, collections, NSUserDefaults, and private APIs right off the bat. No foundation is provided for any of these; it's just a bunch of code that "does it." My approach takes a lot longer (several days at least), but the student ends with an understanding of Cocoa views, the Touch event cycle, and what kind of automatic touch-handling is common in the Apple-provided subclasses. <em>Cookbook</em> gives a recipe for draggable images in a few dozen lines of code.

I've seen the code that comes out of learning this way. New Cocoa developers mistakenly study UIView and UITouch first, and then spend a lot of time reinventing UIScrollView badly (true story). I don't deny its short-term benefits, and this book may very well help you make the one big looming deadline in front of you. But I've spent a lot of time helping debug the kind of code that gets written this way. It's not pretty or quick.

So this book is a good example of what I recommend against in a first book on Cocoa programming. A good Cocoa book should spend a lot of time on the Cocoa design patterns (MVC, delegation, notifications), and give you a solid foundation in Foundation. I know all the exciting, sexy stuff is in UIKit, but without a basis in how to properly manage your object interaction, you're going to wind up with code that fights you every time you turn around. In some ways, iPhone apps are small enough that you might get away with this, but I wouldn't bet on it if you're building more than the latest version of iBeer.

One last point about cookbooks in general: I love cookbooks. One of the most-used books on my bookshelf is <a href="http://www.amazon.com/gp/product/0596003137?ie=UTF8&tag=cocoaphony-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0596003137"><em>Perl Cookbook</em></a><img src="http://www.assoc-amazon.com/e/ir?t=cocoaphony-20&l=as2&o=1&a=0596003137" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />. But it isn't the book I use to teach Perl. <em>Perl Cookbook</em> epitomizes a good programming cookbook by providing carefully-written, easily-applied solutions to non-trivial problems that are too small or specialized to justify a full Perl module. It assumes you already know Perl pretty well, you just need to know the best way to split a string up into individual characters. That's what a good cookbook does.

--

<sup><a name="footnote-1">[1]</a></sup> This is in contrast to .NET which really <em>is</em> just Java with a new syntax and a bunch of arcane widgets that you need to learn.

<sup><a name="footnote-2">[2]</a></sup> For people facing this problem, my usual advice is that when we have no time, that's exactly when we need to make sure we're doing it right the first time. That said, I am well aware of deadline pressures, and for those who just want "working code," Apple provides a great deal of <a href="http://developer.apple.com/iphone/library/navigation/SampleCode.html">Sample Code</a> that cover many of the most important topics from this book.
