---
layout: post
status: publish
published: true
title: Phone-screening Cocoa developers
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: When phone screening potential Cocoa developers, what kinds of questions
  should you ask? I've helped several clients screen potential candidates over the
  years, and so I have several questions I use to help with that.
wordpress_id: 777
wordpress_url: http://robnapier.net/blog/?p=777
date: 2012-06-26 11:15:12.000000000 -04:00
categories:
- cocoa
- Software Development
- iphone
tags: []
---
There was an <a href="http://stackoverflow.com/questions/1019636/phone-screen-questions-for-mac-os-x-developer-positions/1019759#1019759">interesting question</a> on StackOverflow that was unfortunately closed as off topic. It was off topic, but it's still a useful question. When phone screening potential Cocoa developers, what kinds of questions should you ask? I've helped several clients screen potential candidates over the years, and so I have several questions I use to help with that.

<!-- more -->
Now obviously some might be concerned that posting such a list invites people to "study for the test." To that, I have several comments:

* I am not providing answers here, only questions. A potential interviewee who researches the answers is a benefit to everyone.
* This are the minimum basics. They're intended to figure out if someone is even worth talking to. Failure to know these things are a pretty good indication that you *aren't* interested in this candidate. They're not a demonstration of significant skill.
* There's almost always a big difference in the answers between someone who has actually encountered these issues in the real world, and someone who has just recently searched google to crib the answers. It's not usually difficult to tell them apart.
* Anyone who found this list by reading my blog is obviously a developer of exceptional taste and intelligence and should be invited to an in-person interview on the spot.

The first list of questions is for "any" developer, by which I mean any professional, experienced developer. The second list refers to "senior" developers. Most of the questions on that list would be more properly categorized as "intermediate," but senior developers often specialize. One might be an incredible UI programmer who knows little about ObjC internals. Another might be brilliant at developing high-performance data processing with Dispatch I/O, but have trouble managing view rotations. My questions tend to skew a little towards the latter type of developer since that's my speciality. But I try to cover the UI side as well.

Note that several of my questions involve opinions or ask the candidate to "describe generally." None of my questions expect exact, runnable code to be generated on the spot, nor do I expect a candidate to be a walking encyclopedia of Cocoa implementation details. My goal is to explore what the candidate knows intuitively and would know where to look quickly if needed. My goal is not to give a Cocoa pop-quiz. Particularly in a phone screen, most of these questions should be fairly easy to answer for an interesting candidate.

Input welcome as I evolve this list. In particular, I'm looking for senior developers who might feel my questions are too skewed to my skill set. I'd like to keep them as broadly applicable as possible.

So without further ado, some questions.<!--more--><h3>Any Cocoa Developer</h3>

* Should be able to explain the difference between `foo = bar` and `self.foo = bar` when `foo` is an ivar.

* Should be able to easily explain what would cause `EXC_BAD_ACCESS`.

* Should know what happens if you send a message to `nil`.

* Should be able to explain the MVC paradigm, and describe how to break down a simple problem into Models, Views and Controllers. Pay special attention to how they develop Model classes.

* (iOS) Should be able to explain the use of `UITableView`.

* (iOS) Should be able to explain at least one way to fade-out a view that does not involve an `NSTimer`.

* Should know the difference between a view and a layer, and how the two relate to each other.

* Should be able to explain a retain loop and how to prevent them.

* Should be able to explain a retain loop caused by a block capturing `self`. They should be able to describe at least one way to address this problem.

* Should be able to explain what a nib file is, how it is loaded, and (iOS) the order of `UIViewController` methods during creating, loading, displaying, and unloading the main view with and without a nib file (minor mistakes here are ok; but they should be familiar with the overall flow).

* Should be able to describe the debugging steps for the following scenario: "You have a button, an `IBAction`, a text field, and an `IBOutlet`. When you press the button, it should increment the value in the text field. However, when you press the button, the button highlights and unhighlights, but nothing else happens."

* (iOS) Should know how to show and dismiss the keyboard.

* <em>(May become an intermediate/senior topic in the future.)</em> Should know the rules of memory management cold, including the <a href="http://robnapier.net/blog/three-magic-words-6">three magic words</a>. With the rise of ARC, this may eventually become a senior question, but in 2012 every serious Cocoa developer should still be familiar with manual memory management.

* (OSX) Should be able to describe the responder-chain, what it is for, and generally how it works.

* Should be able to describe the difference between the Delegate pattern and the Target-Action pattern and where you would best apply each.


<h3>Anyone Claiming to be a "Senior" Cocoa Developer</h3>

* Should have several defensible opinions on what constitutes Cocoa "best practice."

* Should be able to provide information about a radar they've filed. Any senior developer should eventually have encountered a Cocoa bug, and a good one will have filed a radar. Extra credit for radars cross-posted to openradar.

* Should have specific opinions and complaints about Xcode. Anyone without specific complaints about Xcode hasn't used it very much. Extra credit for radars opened against Xcode.

* Should know the Core Foundation memory management rules and should be able to explain what "toll-free bridging" is.

* Should know how to correctly use `__bridge`, `CFBridgingRetain()`, and `CFBridgingRelease()`.

* (iOS) Should be able to explain several circumstances in which an application may run in the background. In particular, they should be able to explain how to manage long-running operations and when this should be used.

* (iOS) Should be able to explain the use of `UIGestureRecognizer` and give several reasons that a recognizer might not fire when expected.

* Should be able to name several Frameworks outside of Cocoa. Specifically, they should be familiar with at least one Framework that does not link by default and they need to add to their project (any serious developer will have encountered this problem).

* Should know how to apply perspective to `CALayer`. Extra credit if they can explain the difference between a normal layer and a transform layer.

* Should be able to explain an `NSInvocation`, at least to the level of how you would use one.

* Should be able to explain generally KVO's implementation. In particular, "when you call a setter on a KVO observed object, `willChangeValueForKey:` is called automatically, even though it's not in the setter code. How is this achieved?"

* Should be able to design a thread-safe accessor using GCD. Extra credit if it allows simultaneous readers and does not block writers. (Explanation of the basic approach is fine. I dislike on-the-spot coding, even when the developer is onsite.)

* Should be able to explain run loops, why you might manually process one (i.e. `runMode:beforeDate:`), reasons you might manually process the *main* run loop and what dangers that might create.

* Should be familiar with several approaches to debugging memory crashes and leaks, including `NSZombiesEnabled` and malloc debugging. Should be able to describe generally how each of these works.
