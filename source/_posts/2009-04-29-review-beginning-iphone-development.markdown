---
layout: post
status: publish
published: true
title: Review of <i>Beginning iPhone Development</i>
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: 'Beginning iPhone Development: Exploring the iPhone SDK does not provide
  the student a strong foundation in Cocoa, but does teach key iPhone-UI topics well.
  For readers with a prior background in Cocoa, it is likely a good book for transitioning
  to iPhone, particularly iPhone UI.'
wordpress_id: 334
wordpress_url: http://robnapier.net/blog/?p=334
date: 2009-04-29 18:06:05.000000000 -04:00
categories:
- iphone
tags:
- iphone
- Learning Cocoa
- Learning iPhone
- reviews
---
<i>Summary: <a href="http://www.amazon.com/gp/product/1430216263?ie=UTF8&tag=cocoaphony-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=1430216263">Beginning iPhone Development: Exploring the iPhone SDK</a><img src="http://www.assoc-amazon.com/e/ir?t=cocoaphony-20&l=as2&o=1&a=1430216263" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" /> does not provide the student a strong foundation in Cocoa, but does teach key iPhone-UI topics well. For readers with a prior background in Cocoa, it is likely a good book for transitioning to iPhone, particularly iPhone UI.</i>

<i>Beginning iPhone Development</i> is a pretty good book. It assumes you already have some background in ObjC, which makes it harder for people without any Cocoa experience (the most common place to get ObjC experience). A short ObjC intro would have been useful. Like other books in this space, it doesn't provide much background in basic Foundation features like Collections and Notifications, nor key patterns like delegation, memory management and naming. As students move beyond trivial projects, they will likely start to have trouble unless they shore up these skills elsewhere.
<!-- more -->
The step-by-step instructions of the earliest chapters, and the gentle ramp-off of this hand-holding is good in this kind of book, and the style is that of a helpful teacher. Most of the exercises are limited to a single chapter, but they do build within the chapter. That's a good trade-off in a stand-only book. When I teach, I try to keep one project going through many topics so that students can learn how to integrate with existing code and work in non-trivial projects. But in book form, where the student might choose to skip and skim, it can be frustrating if the lessons require all the exercises be completed in order. This book strikes a nice balance.

The order of topics is good. It starts with a nice, simple app that demonstrates the key features of every Cocoa Touch program. It then quickly introduces the student to the various UIControls, and after a slight digression through autorotation and autosizing,<sup><a href="#footnote-1">[1]</a></sup> gets into the meat of view controllers, tab bars, table views and navigation controllers (which are the heart of iPhone UI development).

It could really use some discussion of networking issues, which are a major concern on iPhone. Like most of the iPhone books I've seen, it's focused mostly on UI issues, which is only half the story. As such, it looks like a good book for transitioning someone who already knows Cocoa (and thus Foundation) over to Cocoa Touch. But I think this is a poor first step into Cocoa. I'd certainly consider it as a second book after <a href="http://www.amazon.com/gp/product/0321503619?ie=UTF8&tag=cocoaphony-20&linkCode=as2&camp=1789&creative=390957&creativeASIN=0321503619"><em>Cocoa Programming</em></a><img src="http://www.assoc-amazon.com/e/ir?t=cocoaphony-20&l=as2&o=1&a=0321503619" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />, however.

--

<sup><a name="#footnote-1">[1]</a></sup> I tend to teach view rotation and resizing a bit later, after the students understand tab bars and navigation controllers because of the interactions these have with rotation. But it's a bit of a one-off topic, and it has to go somewhere, and before UIViewController isn't a bad place to put it.
