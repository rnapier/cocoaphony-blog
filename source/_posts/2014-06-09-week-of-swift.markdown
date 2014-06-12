---
layout: post
title: "A week of Swift"
date: 2014-06-09 09:54:30 -0400
comments: true
categories: swift, cocoa
---

The first public beta of Swift has been out for a week. I've been there since
the beginning. I've read almost the entire book and have  written many
*dozens* of lines of Swift code. So as an expert in the field, I'm finally in
a position to write the definitive review of the language. That's a joke, son.
But I'm going to dive in anyway, since that's what you do once you hit your
140 character limit.

First, a spoiler. I basically like Swift. Given its goals and its constraints,
I think it's a move in the right direction. Many of those complaining most
about Swift seem to misunderstand one or the other.

<!-- more -->

So what's the goal of Swift? Apple's been very clear about that. Swift is a
language for building apps for Apple platforms. Period. It isn't meant to be a
general-purpose language. It isn't meant to be a server language. Any
evaluation of Swift starts and ends with how well it lets developers build
really fantastic iOS and Mac apps. Note that I didn't say "build iOS apps
quickly" and I didn't say "build cross-platform mobile apps." I said
"*fantastic* iOS and Mac apps."

This means, among other things, no garbage collected languages need apply. As
our Android friends have learned, when you need great performance in memory
constrained environments, 
[garbage collection is your enemy](http://sealedabstract.com/rants/why-mobile-web-apps-are-slow/).
I was a Mac developer when they added GC and I was at WWDC when they announced
GC was being removed. We all applauded. GC languages were never going to be
considered, and I think that was a great decision. ARC is much better on
mobile (I think it's better in most cases, but it's unquestionably better on
mobile).

In pursuing that goal, Apple also had some constraints. They decided not to
throw away their existing code base (good move), so they needed something that
could work well with Cocoa. A lot of things about Swift would probably be
different if it weren't designed to inter-operate so closely with ObjC. I
expect ObjC to be around for many years, if not indefinitely, as a bridging
language to C. What will be interesting is if ObjC picks up any new features
to better inter-operate with Swift (a typed-collection for instance). If it
does, then ObjC definitely has a very long life ahead.

So for every complaint that comes to mind, think about how it would impact
that goal and that constraint. Would your suggestion make it easier to write
really fantastic apps that integrate tightly with Apple devices and provide
great performance and user-visible features? And would you suggestion make it
easier or harder to work with the existing Cocoa frameworks?

### What I don't like about Swift

Developers often condemn a language before they understand the language.
Everyone should think carefully about [the Blub Paradox](http://www.paulgraham.com/avg.html)
before forming too many opinions. Some things that seem problematic in theory
seldom show up in practice (this is a common situation with first impressions
of Go). And Apple is notorious for doing everything in secret, so it's hard to
know what they're already changing. Even so, there are some things that
currently concern me.

#### Array mutability and copying rules

If there is one thing in Swift that just seems crazy, it's the rules around
Array mutability and copying. Swift doesn't have an immutable array at all. It
has a constant pointer to an array. So you can modify it all you like as long
as you don't change its length. That is a useless kind of immutability. And
even that immutability isn't really intentional. It's just a side effect of
how `let` works on the pointer to the array. This is one of those cases where
Apple really needs to admit that it's a problem, they didn't have time to
address it for the first beta, and they're working on it. The silent treatment
makes them look clueless.

You can argue that immutable arrays aren't that critical and could be fixed
someday. The way `NSArray` returns an `id` is arguably more dangerous than
mutable arrays and we've dealt with it for many years. But then you get to
array copying rules, and those are just crazy. I pass you an array. It's
implicitly a reference to my array and if you modify it, I'll see the changes
UNTIL you modify the length, at which point you'll make a copy and I won't see
the changes anymore. Again, I see how the implementation leads to this, but
it's beyond the pale that Apple would ship that without an apology and a
promise to fix it.

#### That's it?

So far, most everything else I really dislike in Swift is probably transitory
or I'm reserving judgment until I try it for awhile. A few examples:

* Arrays are pretty light on their available methods. Shockingly, there's no
`head` or `tail`. (The most obvious evidence that we're not dealing with a
functional language here.) While it did take us a surprising number of years
to get `firstObject` on `NSArray`, I expect that Swift will certainly add more
methods here, so it's not a concern.

* Swift strings are very light on available methods without bridging over to
NSString. You can't even subscript them to get characters. But again, that's
an obvious enhancement that will almost certainly come quickly.

* The compiler spits out almost useless errors. That's pretty common when you
have overloads and generics. From what I've seen of the compiler team, I'm
quite confident that will steadily improve.

* The distinction between Arrays and Slices is tricky and will likely cause
confusion, and the whole collections type hierarchy (and it's a big one) is a
bit messy in my first estimation (but maybe I just don't get it yet, and it's
not well documented). There's no equivalent of a Scala 
[`Seq`](http://www.scala-lang.org/api/current/#scala.collection.Seq) that I can
find. I'm really surprised that there doesn't seem to be a type for "thing you
can subscript and has a length."[^1] This is one of my bigger concerns because
it may grow harder to fix later, but I'm hoping for a lot of churn in this
hierarchy when they fix the immutable array problem.

[^1]: EDIT: I had said that there was no type for "thing you can enumerate over," but @bddckr made me think about this more, and Sequence does fit that bill.

* `@` seems to be used randomly. It's `@lazy` but just `convenience`. Maybe I
just haven't learned the pattern yet.

Etc. It's minutiae and it's all stuff that will either work out or it won't.
I'll complain louder when I've had some time to see how it goes.

And that's the real take away: We're looking at Swift v0.5 or something. This
is its first trip out in public. It hasn't even been used in major projects
inside Apple (because otherwise it wouldn't have stayed secret). We won't know
if it's going to be any good or not until we start working out how to use it.

I'll have some more thoughts on Swift soon, but that's my first thoughts.
Given a little time, I think it'll be better than what we had before.
