---
layout: post
title: "I, for one, welcome our new Haskell overlords"
date: 2014-08-31 22:25:13 -0400
comments: true
categories: 
published: false
---

I was half-way through two different blog posts, uncertain which to do next, along with all this exploratory work in how I think Futures might work best in Swift, and I was suddenly brought back to a topic I've been mulling over for weeks. @TacticalGrace made a comment that reminded me of it. (Will all my blog posts start with some comment from @TacticalGrace?)

> By not using standard FP terminology in emerging languages like Swift, we deny learners access to a lot of existing literature.

I couldn't agree more. But there's a lot more to it, and I hope the FP community will step up here in way they may not be used to. We'll get there. First, a little history for the rest of us. FP folks, I'll get back to you in a couple of sections.

<!-- more -->

## Objective History

I remember when OOP became a thing in the 90s. I'd been a professional developer for about a decade at that point, shipping products in QuickBASIC, FoxPro, dBase, C, and SL-1 (a phone switching language so obscure it doesn't even have a Wikipedia page). I'd done hobby work in Pascal, various kinds of assembler, and even LISP. But the closest I came to OOP were some toy projects in Borland's Object Windows Library for Turbo Pascal.

This isn't to brag about my old-school hipsterness. If you know me, you know I don't have much of that. My point is that it wasn't so long ago that you could do a lot of professional work and never talk about objects, classes, properties, methods, or any other OOPishnesses.

Then suddenly, Java, and good grief, how could you possibly be a real programmer if you couldn't abstract factory your instance interface? Java didn't invent OOP. Far from it. But suddenly OOP seriously mattered.

>First they ignore you, then they laugh at you, then they fight you, then you
>win. -- Mahatma Gandhi

I remember vividly people laughing at OOP. It was too academic. Too abstract. Too bloated. Too impractical. Too trendy to last. But here we are, maybe 15 years later, and OOP is just how programming is done. When I introduce people to Go, I always have to explain early and repeat often that [Go is not really an object-oriented language](http://golang.org/doc/faq#Is_Go_an_object-oriented_language). That always confuses folks.

Don't get me wrong. Most developers do OOP terribly. Really, really terribly. They keep making horrible design mistakes that we've known for decades are horrible design mistakes. But OOP is how you do things. It's the paradigm in which terrible choices are made today. And good choices too. It's just how things are done. It wasn't always that way.

## Rise of the Lambdas

When I look around at FP today, I see OOP in the 90s. FP keeps creeping into languages. Python, Ruby, JavaScript, C#, and Java didn't start out intentionally functional, but keep picking up functional features. New languages like Swift and Rust self-consciously flirt with functional programming, even if they won't quite commit to it.[^go] Microsoft is pushing F#. Twitter is working in Scala. FP is becoming part of the landscape. Words like *closure* and *comprehension* are invading the vocabulary of professional developers. This has all happened before. This will all happen again. A paradigm is sneaking in when you aren't paying attention. Pay attention.

[^go]: Go is a maverick here, self-consciously *excluding* a lot of functional programming features, other than first-class functions. Go also excluded a lot of OOP features. Go excluded a lot of features in general. That's probably its biggest feature. That and goroutines.

## Please Don't Applicative Functor the Semi-Group

You know what the name of one of the most groundbreaking physics theories is? Superstrings. Yeah, they're these vibrating strings and maybe they make up everything. And what do we call a gravitational singularity? *Black hole*. Beginning of the Universe? *Big Bang*. Physics is filled with words like *antimatter*, *dark matter*, and *inflation*.

My point is that physics, one of the most challenging and mind-blowing subjects out there, is capable of using words that engage the imagination, even if they are inaccurate, sometimes silly, and possibly even misleading. But they open doors rather than close them. Functional programming needs more words like these, or at least more good starting points. We need not to be afraid of metaphor, even bad metaphor. It's not the end of the world if people get their heads around monads as a result in a box. "Contemplate the nature of the monadic laws for a couple of weeks, and then you will begin to understand" cannot be the introduction or FP will be rightly relegated to academia.

There is so much we can use well without fully understanding. Carpenters do not have to learn plant biology, let alone the subatomic nature of matter, before they can learn to work with and against the grain. I'd rather a great carpenter build my house than a great materials scientist. A mathematician may understand best how to combine functions in beautiful and elegant ways, but to ship products I want a programmer.

Right now, our industry needs more FP engineers and sample code. I love that there are those pushing the mathematical borders of combinators. But I want more people turning that into JSON parsers tied to REST clients with local databases and UI animations in popular languages. We need FP experts engaging with the existing platforms, not trying to replace them with Haskell. [Ship you a Haskell](http://robots.thoughtbot.com/ship-you-a-haskell) is a great article, but we mostly work on platforms for which shipping is assumed, not news.

To those of you who don't know Haskell, I'm still telling you to go learn it. It's worth it. I just noticed that Apple's job descriptions for the Foundation team include "Knowledge of Haskell, Rust, F#, or similar languages will be useful." But things that make sense in Haskell don't make sense everywhere. Laziness and ubiquitous currying were language choices, not the one true functional way. They introduced tradeoffs.[^lazy] Languages that chose other tradeoffs can't just take the Haskell approach to problems. They need their own functional idioms. Every language is its own. We shouldn't try to write JavaScript in Swift (seriously, stop it), or Haskell in Swift, or Objective-C in Swift. We should find our way to write great Swift on its own terms. We should learn from our ancestors, not relive their lives.

[^lazy]: Swift's initial attempt at making things lazy by default was a disaster IMO. I'm certainly glad they abandoned that.

## Swift is a Special Flower

Every so often there are special opportunities. Swift represents a real chance to advance the state of best practices in our industry. [Swift isn't functional](/swift-is-not-functional), but it has a lot of very interesting pieces available. And Swift will be extremely popular, by luck of birth as much as anything. I don't mean to disparage the Swift dev team. They've done an admirable job. But if Swift weren't the language of iOS development, it would likely be irrelevant. But since it *is* the favored language of one of an incredibly popular platform, and since it *does* have some useful functional features, it represents an incredible opportunity.

To make the most of that opportunity takes live code in non-trivial apps. Most of my examples come out of a small [Wikipedia front-end](https://github.com/rnapier/WikipediaSearcher) I play with to see how these things might work in practice. I try to solve real problems in a real iOS app and see where it takes me. This is the approach I recommend for any would-be FP evangelist. Build some real programs, or at least serious parts of real programs, including common UI elements, before forming too strong an opinion of what FP should look like in Swift. Engage with stdlib and Cocoa, don't try to replace them. Don't assume stdlib is the way it is out of ignorance. Yes, it's backwards from Haskell. Yes, that makes certain kinds of composition really annoying. Maybe those kinds of composition aren't going to be good Swift, then.

Some concrete points:

* Swift prefers methods over free functions. (This is not a guess. I asked.) Methods auto-complete better and make it easier to document and discover what a particular class can do. I am aware (and I'm *certain* the Swift team is even more aware) of the limitations of methods vs. functions for composition. Swift still prefers methods. There are a lot of limitations on using generics with methods right now. You should expect this to improve rather than for Swift to become more function-centric.
* Swift prefers GCD. The team has said this repeatedly. If you're creating a `Future` (or anything like it) and you're using pthreads, you're fighting Swift and the platform.
* Swift likes Cocoa, Core Data, Core Animation, etc. It seems obvious that the platform will change over time to adapt more to Swift idioms, but you should expect Swift to continue to be tightly bound to Cocoa for the foreseeable future. You should embrace that, not fight it.

How to best implement OOP principles varies from language to language. Arguably JavaScript's prototype system is closer to the original OOP concept than C++ or Java. Objective-C made significant changes on how SmallTalk expressed OOP. You can write good OOP code in ObjC and you can write good OOP code in Java. But if you write Java in ObjC, it'll be bad code. The same is true for FP.




## A Fear of Eagles