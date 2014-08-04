---
layout: post
title: "But should I...Swift?"
date: 2014-07-28 18:13:50 -0400
comments: true
categories: swift cocoa
---

In response to [I Don't Know Swift](http://robnapier.net/i-dont-know-swift):

> Is this career advice? I am a web developer thinking about a "career change"
to iOS. Since I have no background in CocoaTouch or anything Apple, would your
advice be the same, to learn Swift?

I've received different versions of this question since the day after Swift was
released, from ObjC lovers and haters, seasoned pros and the uninitiated. Having
had a very unusual (and privileged) career path, I'm probably not qualified to
give career advice, but I've been asked enough that maybe it's worth talking
about. Maybe I can frame how to think about it, even if I can't give you
satisfying certainty. Maybe that's all advice really is.

 <!--more-->

#### For the iOS newcomer from dynamic, scripting languages

Let me start with the most interesting case to me, and the one that started
this post: you know nothing about iOS and come from mostly a web background.
Should you learn Swift?

Right now is the hardest time you could pick to learn iOS. Does that excite you?
Then absolutely; come learn iOS. You can have an influence on the platform today
in ways that won't come again soon.

But if you stayed away from iOS because of square brackets, I assure you that
today's Swift has a higher learning curve. Someday Swift will be simpler to
learn than ObjC, especially once more of Cocoa is tailored to it.[^cocoa] But
today, crazy features like implicitly unwrapped optionals are something you have
to deal with on day one. We're still working out the best ways to deal with
common coding problems. The handful of tutorials are mostly based on a few days
of experience. And has anyone mentioned that the compiler still crashes *all the
time*.

[^cocoa]: My assumption is that 8.X will clean up some of the Cocoa `!`s and similar tweaks, along with significant optimizer improvements. Then 9 will see some Swift-ification of Foundation (or more Foundation features in Swift stdlib). 10 will see more Swift-ification of UIKit (maybe replacing more selector-based patterns with closures). The specifics are just conjecture, but making iOS development a Swift-centric experience is clearly a multi-release effort.

{% pullquote %}

Yes, Swift calls methods with parentheses. That doesn't make it anything like
JavaScript. The square bracket rules in ObjC are simple, and dot notation is
only slightly more complicated. The rules for parameter names in Swift still
trip me up. {" Today's Swift is not a language for the easily intimidated. "} It
is a language for the curious and the inventor. If you start most projects by
installing a long list of dependencies, Swift probably isn't ready for you quite
yet.

{% endpullquote %}

Swift's syntax looks slightly more like dynamic languages than ObjC. That's an
illusion caused by type inference. Swift is much more strongly typed than ObjC.
It's much closer to Scala than to Ruby. You'll spend a lot of time fighting with
the compiler to accept your program due to confusing type errors. If your
reaction is "thank goodness the compiler is verifying that my code is legal, I
hope they improve the error messages soon," then Swift is your language. If your
reaction is "stupid compiler; I know this code will work fine, just run it" then
you're going to hate Swift.[^types]

[^types]: On the other hand, if you're comfortable with type theory, you may find Swift's type system [a bit limited](http://nomothetis.svbtle.com/type-variance-in-swift). And the stdlib types in Beta 4 are still ugly and restrictive IMO. They're getting better, but they still heavily rely on private details that make implementing your own Collections and Generators very frustrating. I hope this is cleaned up by v1, but I don't know that it will be.

### For the iOS newcomer from strongly-typed, compiled languages

If you're an experienced Java, C#, or C++ programmer, it's possible that Swift
will be a more natural transition than ObjC. The generic programming aspects
have some similarities (though C++ developers will probably be frustrated at the
lack of iterators). If you're a Scala developer, then Swift will probably make
much more sense than ObjC.

But still, as for web developers, this is the hardest time to learn iOS. The
features of Swift are in flux and probably will be for a while. Cocoa is still
Cocoa. If you find `UITableViewController` confusing, absolutely nothing has
changed with Swift.[^tableview]

[^tableview]: And nothing is likely to change in the foreseeable future. The use of delegates and datasources in `UITableView` are on purpose and work exactly as intended. If you don't like that approach, you are unlikely ever to like iOS development. I happen to think `UITableView` is pretty brilliant.

The reason to learn Swift is because you want to develop for iOS. But today,
the *easier* route is to come through ObjC and pick up Swift when it stabilizes.
The reason to learn Swift today is to be part of the beginning of Swift.

### For experienced ObjC devs

If you're shipping Cocoa apps today, clearly you're going to stay in ObjC for
some time to come. You certainly shouldn't go rewrite your whole app. For new
apps, the more complex it is, the more I would suggest ObjC. If it's pretty
simple, it may be a great place to try out Swift, at least for some parts. The
great news is that it's not all or nothing. You can write one class in Swift and
another in ObjC, and it really seems to work pretty well.

Treat Swift like Autolayout.[^carbon] You don't have to jump over the first day
it's released, but eventually you're going to need to come over or things are
going to get harder and harder. The best approach is to experiment with it
early, and migrate as you develop new things. There's no need to jump onto it
day one unless that's your interest. But within 2-3 years, you likely should
do new work in Swift unless there's a specific reason not to. And you should
definitely learn Swift sometime over the next year or two. Clearly that's what
Apple wants long term, and fighting Apple as an iOS dev is a losing game.

[^carbon]: For Mac devs, ObjC is the new Carbon. Take you lessons on its future from that. It'll be around and fully supported for much longer than people expect. But eventually they're going to start breaking ObjC things so that Swift can work better.

### For the iOS newcomer from functional languages and for general language enthusiasts who don't care about Cocoa

I have a whole post planned for you. Stay tuned.

### OK... so what do I do?

Look, do what you want. I've made my career focusing on things that interested
me that later turned out to be commercially valuable. I've been really lucky.
That probably doesn't work for everyone, so who am I to give advice? But since
you asked...

If you're totally excited about Swift, start today. Why are you even asking me?

For other Cocoa-devs, pick up Swift over the next couple of iOS releases.

{% pullquote %} 
For non-Cocoa devs, if you need to ask, then you probably shouldn't jump into
Swift today. If you have the time to learn a new language,
[learn Haskell](http://learnyouahaskell.com). I  hate to be a Haskell fanboi.
I'm not even a very good a Haskell programmer.[^good] That's not the point. The
point is that Swift wants to be functional.
[It isn't functional](http://robnapier.net/swift-is-not-functional), but it wants to be.
So {" if you want to understand the future of Swift, first learn the basics of
Haskell "}.[^haskell] You should be able to read
[Chris Eidhof's JSON Parser](http://chris.eidhof.nl/posts/json-parsing-in-swift.html) and know
why `<*>` and `>>=` were the obvious operators to use. You may agree or disagree
with his parser, but if you can't read Haskell, you won't even understand the 
discussion.
{% endpullquote %}

[^good]: The joke is: Haskell is the language the proves you're a bad programmer. I guess my next post should be titled "I don't know Haskell, either."

[^haskell]: I feel like I should justify "why Haskell rather than X" here. Why not ML, OCaml, F#? But if you follow the FP discussions floating around Swift, Haskell is always front of mind. It's the [only FP language that Chris Lattner calls out](http://nondot.org/sabre/) explicitly as an influence in Swift, and it includes a lot of the concepts that are working their way into Swift. If you're going to pick one FP language to start with, it's the one I recommend.

I remember programming in the mid-nineties when objects started to become "a
thing." Understanding objects, at least the terminology, eventually become an
important part of being a real programmer. OOP had been around for decades at
that point, but it was the mid-nineties when it started to matter. The paradigm
changed, and today many programmers have trouble contemplating programming
without objects. But I did professionally for years. Even as people started to
discuss OOP, there was a lot of resistance because it was too confusing, too
slow, too bloated, to academic. But today, even Fortran has objects.

I see the same things happening today in functional programming. After decades
of existing on the edges of the profession, it now comes up often in mainstream
discussions, and it will definitely continue to influence Swift. When Swift is
finally ready for you, you'll be much more ready for Swift.

So that's my advice, for what it's worth. Get ahead of that wave. When you do
that, you'll have a useful skill no matter the platform. But more about that in
my next post.

And then yeah, sure, come play with us in Swift. It's a blast!

