---
layout: post
title: "I don't know Swift"
date: 2014-07-18 11:04:22 -0400
comments: true
categories: swift cocoa
published: true
---

I know a thing or two about Objective-C. It's not bragging. If you're reading my
blog, there's a decent chance that I know more about Objective-C than you do. I
have opinions about it. You should take them seriously even if you disagree.
They're founded on shipping a lot of code. I've shipped Cocoa software solo and
in big teams, OS X and iOS, year-long release cycles and 30 hours to build a
demo for Steve Jobs. I've been writing ObjC since 10.4 was the new hotness,
before ARC, before properties, before Intel. There are many developers with much
more experience, but even so, I know a thing or two about Objective-C.

I have no idea how to write Swift.

Neither does anyone else.

Not even Apple.
<!-- more -->

Nobody knows Swift because it isn't baked yet. It's early days. We're all still
figuring it out. There are no established patterns. The syntax is still
changing. The stdlib is still changing. We know even more big changes are on the
horizon.[^access] Writing the compiler isn't the same as shipping an app. Some
things take real-world experience, and no one has that.

[^access]: Can you say access controls? We know they're coming. We don't know what they'll look like.

Tim Burks[^tim] wrote a [provocative radar](http://www.openradar.me/17628154)
recently:

[^tim]: ...whose opinions I take quite seriously. He's a smart, insightful guy. [Nu](http://programming.nu) is an interesting language. I even agree with some of his frustrations about Swift. [We just disagree on what to do about them.](https://twitter.com/cocoaphony/status/487331425369063424)

>...I'd like to suggest that the appropriate way to introduce a new language is
for its creators to spend several months writing nontrivial applications in the
language and reviewing the results with experts. This does not seem to have been
done.

That's how it's often done. People with language design experience work on a new
language, mostly in secret or obscurity. They release it to some people, maybe
internally. A small community starts to form. These are the insiders, the first
adopters. They try things. They tinker. They build bigger things. They at least
build some large libraries (Go's stdlib, parts of .NET for C#). They revise the
languge based on what they learn. More people come. Maybe it becomes public or
maybe it just gains some "critical mass" and new, uninitiated people start to
use it for more serious things and maybe it even becomes "important."

Swift has come naked into the world. Half-baked. Some parts ill-considered and
changing dramatically before our eyes. Most of its libraries are still in ObjC,
C, and C++. It's just the beginning and you're all here. You're those early
adopters, usually that tiny, almost hand-picked group. But there are thousands
of you this time, here in the priomordial era.

You can think this is good or bad, but it's definitely a special opportunity. I
predict with great confidence that Swift will be
[TIOBE's](http://www.tiobe.com/index.php/content/paperinfo/tpci/index.html)
language of the year. It entered the list at #16 and it isn't even released yet.
And here you are. Not just on the ground floor, but standing on the newly poured
foundation. It seems pretty solid, but it's not a building quite yet.

Imagine if Google had said "Go is the future for Android development" or
Microsoft had recommended all C# developers move to F#. Apple has made Swift the
preferred language for one of the most popular platforms in existance. I expect
they'll follow through with that.
["Any evaluation of Swift starts and ends with how well it lets developers build really fantastic iOS and Mac apps."](http://robnapier.net/week-of-swift/)
I belive Swift meets that criteria even better than ObjC (and I love ObjC). I
don't see any reason Apple would back away from Swift now.

So there you go. You're here at the beginning. There is no priesthood. There are
no old folks sitting on rocking chairs cussing your new-fangled dot-syntax. You
are the old folks. You remember before immutable arrays.

You're a day-zero Swift expert, and if you're not, you could be a year-zero
Swift expert even if you wait for iOS 8 to ship. The niches are all still open.
Read everything.[^mylist] Write [something](https://github.com/maxpow4h/swiftz).
Get involved. Try out new patterns, see if they work. Tell people what you 
discover.[^let]

[^mylist]: BTW, my current favorite Swift blogs are [Airspeed Velocity](http://airspeedvelocity.net) and [nomothetis (Alexandros Salazar)](http://nomothetis.svbtle.com). Highly recommended. They're teaching me a lot. I'd love to see more people writing this way.

[^let]: For example, I've found that `if let x = x { ... }` (rebinding to the same identifier) is a pretty good style for unloading an optional. I've also found that `map()` on an optional can be a handy replacement for `if-let` when you can't use chaining. For example: `let optY = optX.map{Y(x:$0)}`. An extension on `Optional` to wrap `map` in a function called `ifSet` can make this a little easier to read.

And most of all, if things in Swift bother you, if they don't work for you, if
they could be better, say it now. Open radars.[^radar] Post on devforum. Write
an example. Show why your way makes the code better. Swift is still changing,
and it's in beta exactly so it can change. It may be a long time before you
have this chance again.

[^radar]: Yes, radar stinks; do it anyway, it's not that bad. And from the forums, the Swift team is clearly reading and reacting to the radars they receive.