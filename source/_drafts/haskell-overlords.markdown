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

What's a biscuit joiner?
: It's a tool for extracting parallel planes comprising half of a negative ovaloid prism.

What's a monad?
: It's an endofunctor with two natural transformations satisfying associativity and identity.

*Let's try that again.*

What's a biscuit joiner?
: It's a tool for cutting slots in the edges of boards. You put a little piece of wood in there (called a "biscuit") so you can glue panels together, like for a tabletop or door.

What's a monad?
: It's a result in a box. You can use them to chain together operations that might fail, or might happen in the future, or otherwise have some "context" around them that you want to pass along with the result itself.

None of the definitions above are complete or fully correct. But the last two are *useful*. After reading the second definition of a biscuit joiner, I wouldn't expect you to be able to even recognize one, let alone use it safely, but you'd at least know when you might want to find out more about it.

The same is true for how we introduce FP concepts. We need not to be afraid of metaphor, even bad metaphor. I'm looking for better metaphors; better starting points. But starting a monad discussion with an introduction to the monadic laws closes the conversation. It says this is something unrelated to common programming problems.

There is so much we can use well without fully understanding. Carpenters do not have to learn plant biology, let alone the subatomic nature of matter, before they can learn to work with and against the grain. I'd rather a great carpenter build my house than a great materials scientist. A mathematician may understand best how to combine functions in beautiful and elegant ways, but to ship products I want a programmer.

Right now, our industry needs more FP *engineers* and sample code. I love that there are those pushing the mathematical borders of combinators. But I want more people turning that into JSON parsers tied to REST clients with local databases and UI animations built on popular frameworks. We need FP experts engaging with the existing platforms, not trying to replace them with Haskell. [Ship you a Haskell](http://robots.thoughtbot.com/ship-you-a-haskell) is a great article, but most of us work on platforms for which shipping is assumed, not news.

To those of you who don't know Haskell, I'm still telling you to go learn it. It's worth it. I just noticed that Apple's job descriptions for the Foundation team include "Knowledge of Haskell, Rust, F#, or similar languages will be useful." But things that make sense in Haskell don't make sense everywhere. Laziness and ubiquitous currying were language choices, not the one true functional way. They introduced tradeoffs.[^lazy] Languages that chose other tradeoffs can't just take the Haskell approach to problems. They need their own functional idioms. Every language is its own. We shouldn't try to write JavaScript in Swift (seriously, stop it), or Haskell in Swift, or Objective-C in Swift. We should find our way to write great Swift on its own terms. We should learn from our ancestors, not relive their lives.

[^lazy]: Swift's initial attempt at making things lazy by default was a disaster IMO. I'm certainly glad they abandoned that.

## Swift is a Special Flower

Every so often there are special opportunities. Swift represents a real chance to advance the state of best practices in our industry. [Swift isn't functional](/swift-is-not-functional), but it has a lot of very interesting pieces available. And Swift will be extremely popular, by luck of birth as much as anything. I don't mean to disparage the Swift dev team. They've done an admirable job. But if Swift weren't the language of iOS development, it would likely be irrelevant. But since it *is* the favored language of an incredibly popular platform, and since it *does* have some nice functional features, it represents an incredible opportunity.

To make the most of that opportunity takes live code in non-trivial apps. Most of my examples come out of a small [Wikipedia front-end](https://github.com/rnapier/WikipediaSearcher) I play with to see how these things might work in practice. I try to solve real problems in a real (if small) iOS app and see where it takes me. This is the approach I recommend for any would-be FP evangelist. Build some real programs, or at least serious parts of real programs, before forming too strong an opinion of what FP should look like in Swift. Engage with stdlib and Cocoa, don't try to replace them. Don't assume stdlib is the way it is out of ignorance. Yes, it's backwards from Haskell. Yes, that makes certain kinds of composition really annoying. Maybe that just means those kinds of composition aren't going to be good Swift.

Some concrete points:

* Swift prefers methods over free functions. (This is not a guess. I asked.) Methods auto-complete better and make it easier to document and discover what a particular class can do. I am aware (and I'm *certain* the Swift team is even more aware) of the limitations of methods vs. functions for composition. Swift still prefers methods. There are a lot of limitations on using generics with methods right now. You should expect this to improve rather than for Swift to become more function-centric.
* Swift prefers GCD. The team has said this repeatedly. If you're creating a `Future` (or anything like it) and you're using pthreads, you're fighting Swift and the platform.
* Swift likes Cocoa, Core Data, Core Animation, etc. It seems obvious that the platform will change over time to adapt more to Swift idioms, but you should expect Swift to continue to be tightly bound to Cocoa for the foreseeable future. You should embrace that, not fight it.

None of these points stop Swift from enjoying great value from functional approaches. But they do mean that what good functional approaches look like in Swift may differ from other languages. How to best implement OOP varies too. Arguably JavaScript's prototype system is closer to the original OOP concept than C++ or Java. Objective-C made significant changes on how SmallTalk expressed OOP. You can write good OOP code in ObjC and you can write good OOP code in Java. But if you write Java in ObjC, it'll be bad code. The same is true for Haskell (or ML or F#) and Swift.

## A Call to Arms

So at the end of all this, I'm looking for help. I believe the most important lesson from functional programming is that mutable state is the enemy. FP brings us many other things, but its lessons about mutable state and referential transparency provide incredible value at very little cost. Just getting developers to use `let` rather than `var`, to use `map` rather than `for`, to enumerate rather than subscript, to transform rather than mutate, would eliminate many bugs and make our programs clearer and more robust. I know this is boring "of course" kind of stuff for most developers with FP experience, but when I look at Swift code on StackOverflow, it's all crazy mutating state.

Second only to immutability are types. Actually, `AnyObject` is probably worse than `var`... It's a tough call.

Evangelize those things before you worry about currying. Teach how to work with immutable data structures before bothering with functional composition. Once you start teaching immutability, suddenly you need `map`. Once you have `map`, you suddenly want to combine it with other things. When you combine a lot of things, you find you want a monad. Then you realize you've got a lot of stuff that looks the same and you find yourself at functor and applicative. All the other lessons come up out of teaching immutability and types. Don't do them backwards. Don't assume that other programmers intuitively know that state is the enemy. They don't. We need to tell them.

I want help finding easily approachable, reasonably accurate ways to introduce some of the more important concepts. I want help identifying the more important concepts. Not the things that are most important for understanding the math; the things that are most important for writing and maintaining great Cocoa apps.

I think Swift is missing a few things that are really critical to applying FP concepts to great Cocoa apps. The most important to me is a `Result` object (`Either<NSError, T>`). The second most important thing that's missing is a `Future`. I've begun work on those in [LlamaKit](https://github.com/llamakit/llamakit). I'm looking for help discovering what other things are essential to writing better Cocoa apps. You can join the conversation on the [LlamaKit mailing list](https://groups.google.com/forum/#!forum/llamakit).

## A fear of eagles

Occasionally, in my more self-aggrandizing moments, I fear I am Prometheus, stealing fire from the gods to bring back to programmers struggling in the dark. I worry about being torn between a camp devoted to mathematical purity, and a "shut up and ship it" camp uninterested in learning magical operators. And I remember what came of Prometheus.

I then realize I'm just a programmer and teacher. And I notice that the paradigm is shifting. And I think it's a pretty good moment to light a fire.