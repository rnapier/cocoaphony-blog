---
layout: post
title: "La Trahison du Temps"
date: 2016-12-17 14:01:59 -0500
comments: true
categories:
---

->![La Trahison du Temps](/images/trahison.png)<-
<!-- more -->

If you've ever said "this `Date` is in local time, but that `Date` is in UTC," you don't understand `Date`, and this post is written for you. I may ramble a little about philosophy, but stick with me. What we're going to talk about today is very practical, and when you understand it, you'll avoid one of the most common mistakes in Cocoa.

We discovered time, but we invented dates. That's why date programming is hard. Dates are all about people, and people are weird, so dates are weird. Time is simple, at least to a first approximation, at least on the scale that humans experience it. So when programmers confuse dates and times, they over-simplify one and over-complicate the other.

## What is time?

So what is time if it's so simple? For our purposes, it's just when things happen. I want you to put away any fancy Relativistic notions you think you know from skimming Wikipedia. Those don't matter here. I want you to forget about clock skew and leap seconds. For today, we all have a stopwatch, and if we reset our stopwatch together (which we can do because we say we can), we will always agree on how much time has passed since then. Writing software is math, and math says you can make up any rules you like, and those are our rules. Time is simple because we say it's simple.

So if we all agree on how much time has passed, how do we represent that? With a `TimeInterval`, which is a vector in time. Time is one-dimensional, so we can represent our vector with one signed number scaled to some unit (seconds). And that's what we do. In Cocoa, `TimeInterval` is just a typealias for `Double`.[^double]

[^double]: I wish it weren't a typealias because then we could put extensions on it without extending `Double`, but that's how it is.

So, when our `TimeInterval` says 120 seconds, what is it in Greenwich? *Umm… 120 seconds.* And what is it in San Francisco? *Umm… 120 seconds.* And what is it on the Moon or on Mars? *Umm… why do you keep asking stupid questions? It's always going to be 120 seconds for everyone!*

Exactly. Hold that thought.

## What is a date?

How many seconds is it between now and 2:00 PM? Well, that depends, doesn't it? Where are we? If you look at your clock and it says 1:00 PM, then you might say 3600, but would someone 1000 miles to the east or west agree? What if you were traveling and crossing time zones? What does "how long until 2:00 PM" mean in that case? If you cross back and forth over a time zone line, you could avoid 2:00 PM indefinitely. What would someone on the Moon or Mars say? Does 2:00 PM make sense if you're not on the Earth? Clearly "now until 2:00 PM" isn't an unambiguous time interval. It requires a lot of context and might not even be a meaningful question.

But maybe the problem is that the question includes "now." Let's try something simpler. I want to sleep eight hours, and it is now 10:00 PM. When time should I wake up? There are at least three answers, depending on what day it is and what the local DST rules are. But if we are on the Moon, it might be something completely different.

I like throwing the Moon in as a test because it forces you to think about context. If a calculation works the same on the Moon as it does in New York, then we are just talking about time. But if we need more context, then we probably need a date.

## What is a `Date`?

So what does that tell us about `Date`? It tells us that `Date` is actually a time. In fact, it's an *absolute point* in time. That means if I have a `Date` and you have a `Date`, we will always agree which one occurs first. And this really is an *absolute* point in time. It's not relative to anything. If I create a `Date` using `Date(timeIntervalSince1970:)` and you create a `Date` using `Date(timeIntervalSinceReferenceDate:)`, we *still* will agree which one comes first. From the public interface, all `Date` objects are directly comparable. I can always subtract two `Date` objects, with no other information, and get a `TimeInterval` that everyone will agree on..

Compare this to `CGPoint`, which is not a point. It's an offset (vector) applied to some unknown origin. If I give you two `CGPoint` objects, you can't tell me which one is "to the left" of the other unless I tell you separately what coordinate spaces they come from (and how those coordinate spaces relate to each other, if at all).[^gte]

So here's the takeaway. **If you think a `Date` is "in" some timezone, you misunderstand `Date`.** A `Date` does not care what city or planet you're on, what day it is, or what calendar you use. Everyone can agree on when a `Date` occurs. It neither requires, nor is influenced by, any external factor.

[^gte]: Thanks to [Guy English](https://twitter.com/gte/status/809541556097130496) for pointing this out.

## Stop throwing away the context

OK, so I've ranted on about this for quite a while. Why do we care?

Because developers *often* throw away necessary context by switching from a date to a time when they shouldn't. Let's say you're writing a calendaring app and a user creates an appointment for [9:00 AM on March 21, 2017 in Yosemite National Park](http://cocoaconf.com/yosemite). You want to store your data correctly, so you convert it to a "UTC `Date`" and store it.[^utc]

[^utc]: As we discussed, there's no such things as a "UTC `Date`," but I hear people say this all the time.

    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .long
    let date = formatter.date(from: "Mar 21, 2017, 9:00:00 AM PST")

**This is almost certainly wrong.**

According to current law, on March 12, 2017, Yosmite will go from PST to PDT, and that's the assumption you've stored in `date`. But what if the law changes? "Oh, that would never happen." [Tell that to Microsoft.](https://kb.iu.edu/d/atrm) In 2006, Indiana started observing DST, and Exchange calendars messed up their meeting times because they stored everything in UTC. In 2007, the whole United States changed the dates of DST observance and Exchange calendars broke again. Canada and Australia also changed their rules in 2007, Australia changed them again in 2009. Chile abolished it in 2015, but re-introduced it in 2016 (but not everywhere). Egypt, Haiti, and Uruguay abolished it in 2015. Tongo will started observing it in 2016. Until 2013, Israel [changed the rules unpredictably every year](https://en.wikipedia.org/wiki/Israel_Summer_Time#2005.E2.80.932012). Morocco changes four times a year rather than twice. The list goes on and on. Many countries (including the United States) continually debate whether to do away with DST, so future changes should not be a surprise (Hungary will abolish it in 2017). If you're storing future dates as "seconds since the epoch" or "UTC," you're gambling that nothing is going to change in a field where things change all the time.

The problem is that "Mar 21, 2017, 9:00:00 AM PST" is not a time. It is the *name* of a time. And it's possible that it refers to multiple times or to no time at all.
