---
layout: post
title: "Blogging about logging"
comments: true
published: false
categories: 
---

Before your code ships, the most important bug-squashing tools available are ubiquitous code review and consistent naming. But *after* your code ships, the most important bug-squashing tool available is logs.

Most teams I know treat logs as a development tool. After all, what's the first thing you do when you get ready to ship? Turn the log levels down, maybe even turn them off entirely. What are you thinking? That's when you need those "debug" logs the most! When you're developing you have a debugger and test cases. You run things over and over and see what happens. But once you ship, the logs are all you have. That's when they matter most. I've solved more customer issues by reading logs than with any other tool.

Today I'm mostly going to talk about philosophy and design. I'll show a little code, but what I want you to take away is how to build a good logging system and how to have a good approach to logging. I generally wind up building a custom solution for each major project I work on, and I've built various versions in Perl, C++, ObjC, Go, and Swift, so this really isn't about one framework or another. I often wind up gutting an existing framework and turning it into what I want. (In Swift, I used SlimLogger as my skeleton. In Go, it was Logrus.)

*Note: I'm going to talk mostly about user-facing systems. Mobile apps, desktop apps, even services that run on user systems or on small servers. The logging problems of large-scale servers/cloud are different and much of my advice may not apply. In particular, the performance trade-offs are wildly different. Microarchitectures also create a different set of logging problems. In short: if your logs are mostly consumed by developers, then my advice is going to be helpful. If they're heavily consumed by ops, then there may be some pieces you can glean here, but it's not my expertise.*

## The log you don't have is worthless

My first rule is the most important and I hope the least surprising. *You need to be able to get the logs from your customers.* It seems so obvious when you say it out loud, but I find team after team who don't address this basic fact. There are a lots of ways to go about this with various tradeoffs.

The simplest approach is to just help your customers mail you logs. I've done this with something as simple as an `MFMailComposeViewController` on iOS. If you build services for desktops or servers, then a small script that will package up the logs and mail them can be invaluable.

Moving up in value is a system for automatically gathering logs in the case of a crash. For iOS, I've been very happy with Crashlytics for this, but there are other good services. Capturing a crash report is very hard to do correctly. You can deadlock really easily. I highly recommend, on all platforms, that you use a well-established library. But even if you don't, there are things you can do to capture the logs. Every time you launch, record something (write a file, store something in the database, make a key in `NSUserDefaults`). Every time you exit, clear that something. If when you launch, you find it already there, then you know you somehow terminated unexpectedly. It might be nothing. The device might have been turned off or you might have been killed by the user. But it's a hint that you may have crashed, and that's a good time to send yourself some logs.

Beyond that is logging services. I personally like Loggly, but there are many good ones. I generally spool things to disk for a while and periodically upload in bulk. In most systems you should also upload when you're terminating or launching. On iOS, I like to upload when terminating. Then if I still have logs lying around when I launch, I know something went wrong.