---
layout: post
status: publish
published: true
title: Obfuscating Cocoa
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: "Cocoa is a reverse-engineer’s dream. Spend some time at culater before dreaming
  you can really protect a Cocoa program. Objective-C is meant to be highly readable
  both in source and at run time. Obfuscation is not in its nature. This only points
  out Objective-C’s particular difficulties in this area; it is not to suggest C or
  C++ will save you. They’re just not quite as trivial as Objective-C. That said,
  the world of obfuscation falls into three big camps: you can try to deal with 70%
  of your problem, 75% of your problem or 90% of your problem.\r\n"
wordpress_id: 389
wordpress_url: http://robnapier.net/blog/?p=389
date: 2009-06-26 14:28:27.000000000 -04:00
categories:
- cocoa
- Security
tags:
- cocoa
- Security
---
<i>We recently had a discussion on cocoa-students (the excellent list for Big Nerd Ranch alumni; yet another reason to go to BNR classes) about protecting Cocoa programs from reverse engineering, mostly around some anti-copying code. I had some thoughts on the subject since I happen to have a background in anti-counterfeiting.</i>

Cocoa is a reverse-engineer's dream. Spend some time at <a href="http://www.culater.net/wiki/moin.cgi/CocoaReverseEngineering">culater</a> before dreaming you can really protect a Cocoa program. Objective-C is meant to be highly readable both in source and at run time. Obfuscation is not in its nature. This only points out Objective-C's particular difficulties in this area; it is not to suggest C or C++ will save you. They're just not quite as trivial as Objective-C.

That said, the world of obfuscation falls into three big camps: you can try to deal with 70% of your problem, 75% of your problem or 90% of your problem.
<!-- more -->
Dealing with 70% of your problem requires nothing more than pretty straightforward techniques. The majority of users will not download cracked copies, so almost anything will work. I tend to recommend this approach. Focus on your good customers; do *nothing* to tick them off, but consistently encourage them to give you money as they are naturally inclined to do. Any technique intended to stop the other 30% should be very carefully run through cost/benefit. How many of those 30% who wouldn't have paid you before now will? How many of those 70% who would have paid you before now won't because your "copy protection" drives them crazy? How much money do you spend to get that delta? This is revenue protection analysis, and should be a key part of any anti-copying discussion.

Dealing with 75% of the problem is where most folks seem to eventually go, and it's perhaps the most foolish. They try to build their own complex solutions, which just make things more complicated while only impacting the small group of people who would have attacked your product before, but you can actually stop with code you come up with in the 4 weeks you're willing to devote to the problem. It's not a big group. Most people who actually would take the trouble to break your simple solution can also break your complicated solution. And it only takes a few to do it and post it to Bittorrent. Apple spends a *lot* of money to harden the iPhone from jailbreaking, and they still can barely keep ahead (and generally don't keep ahead).

Dealing with the 90% solution means hiring folks who do this full time, or licensing solutions from folks who do this full time. It means constantly evolving your system to adapt to new attacks. It means making this a full-time commitment for your company. See my discussion of Apple and jailbreaking. That's the 90% solution.

There is no 100% solution. There isn't even a 95% solution.

This used to be my full-time job. We controlled the hardware, the software, custom ASICS and PKI smart chips. We controlled the manufacturing and the sales channel. We used special security tapes and labels and holograms and some really funky techniques typically used in protecting currency. We sent people like me all over the world to monitor our partners and called in the police to conduct raids. Still, copies.

This is not a solvable problem. It is only a manageable problem.
