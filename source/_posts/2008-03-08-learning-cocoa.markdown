---
layout: post
status: publish
published: true
title: Learning Cocoa
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: "It's a lazy day for me. That means I'll probably hack stuff all day.\r\n\r\nOne
  of my best friends in the world just sent me a note asking for a good Cocoa reference.
  I thought I'd pass on the same advice I gave him:\r\n\r\nThis is <strong>the</strong>
  book on learning Cocoa:\r\n\r\n<a href=\"http://www.amazon.com/gp/product/0321503619?ie=UTF8&tag=cocoaphony-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0321503619\">Cocoa
  Programming for Mac OS X</a><img src=\"http://www.assoc-amazon.com/e/ir?t=cocoaphony-20&l=as2&o=1&a=0321503619\"
  width=\"1\" height=\"1\" border=\"0\" alt=\"\" style=\"border:none !important; margin:0px
  !important;\" /> by Aaron Hillegass\r\n\r\nThird edition is supposed to come out
  this summer. I've read the proofs of the 3rd edition, and it does add some good
  stuff, but if you're anxious to get started, I'd get 2nd edition and get started."
wordpress_id: 95
wordpress_url: http://robnapier.net/blog/?p=95
date: 2008-03-08 10:59:43.000000000 -05:00
categories:
- cocoa
tags:
- cocoa
- Interface Builder
- Learning Cocoa
---
It's a lazy day for me. That means I'll probably hack stuff all day.

One of my best friends in the world just sent me a note asking for a good Cocoa reference. I thought I'd pass on the same advice I gave him:

This is <strong>the</strong> book on learning Cocoa:

<a href="http://www.amazon.com/gp/product/0321503619?ie=UTF8&tag=cocoaphony-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0321503619">Cocoa Programming for Mac OS X</a><img src="http://www.assoc-amazon.com/e/ir?t=cocoaphony-20&l=as2&o=1&a=0321503619" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" /> by Aaron Hillegass

Third edition is supposed to come out this summer. I've read the proofs of the 3rd edition, and it does add some good stuff, but if you're anxious to get started, I'd get 2nd edition and get started.<a id="more"></a><a id="more-95"></a>

I may sound like a terrible shill for Aaron, who also happens to be a very nice guy and an excellent instructor, but this really is <strong>the</strong> book on the subject. Poll any group of Cocoa developers and it'll come up over and over again either as the book they used or the book they would have used if it had existed when they started.

Do not just sit down and read this book in bed. Get our XCode and work through the projects. Even just re-typing code out of the book will teach you a lot. You'll learn how to get around XCode and how Objective-C "feels" to type. That may sound silly, but Obj-C doesn't type like other languages. The method names are very long and multi-part, so using the built-in code completion is much more useful than it may be in Java or C++.
The one problem with starting with 2nd Edition is that its written for Interface Builder 2, and 10.5 moved to IB3. You have several choices: wait for 3rd edition (don't. get started learning this week, you'll thank yourself later); download XCode 2.5 from Apple and learn using that (not a bad solution); or read the IB help, particularly "Interface Builder Workflow Tools."

Here is the one huge secret that will make things easier moving from IB2 to IB3: If you want to instantiate a custom class, the IB2 way was to go into the class browser, find the class you wanted and select "Instantiate" for it. There is no class browser in IB3, so you'll hunt forever.... The answer is to drag an NSObject or NSView from the library onto your object window (the one with "File's Owner" in it), then go to the Identity pane of the Inspector and set the Class. This is a really unintuitive way to do a very common operation. It took me ages to figure it out with my background in IB2. Yes, it makes sense, but you shouldn't have to click that much to find it.

If you have any interest in being a Cocoa programmer, go do it. A great book is available at a reasonable price. All the same tools that the professionals use are available for free with the OS. There's nothing stopping you from building little (but useful) Cocoa apps a month from now.
