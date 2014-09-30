---
layout: post
title: "I, for one, welcome our new Haskell overlords"
comments: true
categories: functional swift haskell
date: 2014-09-29 10:57
---

[Manuel Chakravarty](https://twitter.com/TacticalGrace/status/506079987565613056) made a comment a few weeks ago:

> By not using standard FP terminology in emerging languages like Swift, we deny learners access to a lot of existing literature.

I certainly agree. But there's a lot more to it, and I hope the functional programming community will get involved in new ways. We'll get there. First, a little history for the rest of us. FP folks, I'll get back to you in a couple of sections.

<!-- more -->

## Objective History

I remember when OOP became a thing in the 90s. I'd been a professional developer for about a decade at that point, shipping products in QuickBASIC, FoxPro, dBase, C, and SL-1 (a phone switching language so obscure it doesn't even have a Wikipedia page). I'd done hobby work in Pascal, various kinds of assembler, and even Lisp. But the closest I came to OOP were some toy projects in Borland's Object Windows Library for Turbo Pascal.

This isn't to brag about my old-school hipsterness. If you know me, you know I don't have much of that. My point is that it wasn't so long ago that you could do a lot of professional work and never talk about objects, classes, properties, methods, or any other OOPishnesses.

Then suddenly, Java, and good grief, how could you possibly be a real programmer if you couldn't abstract factory your instance interface? Java didn't invent OOP. Far from it. But suddenly OOP seriously mattered.

>First they ignore you, then they laugh at you, then they fight you, then you win. -- Mahatma Gandhi

I remember vividly people laughing at OOP. It was too academic. Too abstract. Too bloated. Too slow. Too confusing. But here we are, maybe 15 years later, and OOP is just how most programming is done.

Don't get me wrong. Most developers do OOP terribly. Really, really terribly. They keep making horrible design mistakes that we've known for decades are horrible design mistakes. But OOP is how you do things. It's the paradigm in which terrible choices are made today. And good choices too. It's just how things are done. It wasn't always that way.

## Rise of the Lambdas

{% pullquote %}

When I look around at FP today, I see OOP in the 90s. FP keeps creeping into languages. Python, Ruby, JavaScript, C#, Java. They didn't start out intentionally functional, but they keep picking up functional features. New languages like Swift and Rust self-consciously flirt with functional programming, even if they won't quite commit to it. Microsoft is pushing F#. Twitter is working in Scala. FP is becoming part of the landscape. Words like *closure* and *comprehension* are invading the vocabulary of professional developers. This has all happened before. This will all happen again. {" A paradigm is sneaking in when you aren't paying attention. Pay attention. "} There's a chance here to influence development practice for decades, for good or ill.

{% endpullquote %}

## Please Don't Applicative Functor the Semi-Group

**What's a biscuit joiner?** It's a machine for generating half of a negative ovaloid prism.

**What's a monad?** It's an endofunctor with two natural transformations satisfying associativity and identity.

Let's try that again....

** What's a biscuit joiner?** It's a tool for cutting slots in the edges of boards. You put a little piece of wood in there that sticks out as a tab (called a "biscuit") so you can glue panels together, like for a tabletop or door.

**What's a monad?** It's a result in a box. You can use them to chain together operations that might fail, or might happen in the future, or otherwise have some "context" around them that you want to pass along with the result itself. A Swift optional is one kind of monad, where the "context" is whether it actually has a value or not.

None of the definitions above are complete or fully correct. But the last two are *useful* for people likely to be asking. After reading the second definition of a biscuit joiner, I wouldn't expect you to be able to even recognize one, let alone use it safely, but you'd at least know when you might want to find out more about it.

{% pullquote %}

The same is true for how we introduce FP concepts. {" We don't need to be afraid of metaphor, even slightly strained metaphor. "} I'm looking to people more expert than I am for better metaphors, better starting points. Maybe my monad intro could be improved. I'm aware that it doesn't perfectly explain why lists are also monads. But starting the discussion with monoids and the monadic laws closes the conversation. It says this is something unrelated to shipping products. It shouldn't be in the first paragraph, let alone the first sentence. It's better to start a bit wrong and build on that, than to start more correct (but still a little wrong) and make an important tool seem irrelevant.

{% endpullquote %}

I'm not saying we shouldn't use FP terms, even opaque terms of art from category theory. I agree with what Manuel was saying at the start of this. We should call a monad a monad. We should even probably call a functor a functor (though I have a fondness for "mappable"). I'm just saying we should introduce them in ways that engage the goal, which is great shipping software, not proofs for their own sake.

There is so much we can use well without fully understanding. Carpenters do not have to learn plant biology, let alone the subatomic nature of matter, before they can learn to work with and against the grain. I'd rather a great carpenter build my house than a great materials scientist. To ship great products, I want a programmer, not a mathematician.

I want more people turning FP concepts into JSON parsers tied to REST clients with local databases and UI animations built on popular frameworks. We need FP experts engaging with the existing platforms, not trying to replace them with Haskell. [Ship you a Haskell](http://robots.thoughtbot.com/ship-you-a-haskell) is a great article, but most of us work on platforms for which shipping is assumed, not news. "Employs total referential transparency" isn't particularly useful for my AppStore blurb if the program is late and the animations are glitchy. FP is a means to an end for most projects, not the end itself.

To those of you who don't know Haskell, I'm still telling you to go learn it. It's worth it. I just noticed that Apple's job descriptions for the Foundation team include "Knowledge of Haskell, Rust, F#, or similar languages will be useful." But things that make sense in Haskell don't make sense everywhere. Haskell is just a language. Ubiquitous laziness and currying were choices of one language, not the one true functional way. They introduce tradeoffs.[^lazy] Languages that chose other tradeoffs need their own functional idioms. We shouldn't write JavaScript in Swift (seriously, stop it), or Haskell in Swift, or ML in Swift, or even Objective-C in Swift. We must find our way to write great Swift on its own terms. We should learn from our ancestors, not just relive their lives.

[^lazy]: Swift's initial attempt at making things lazy by default was a disaster IMO. I'm glad they abandoned that. It just didn't work with the rest of Cocoa.

## Swift is a Special Flower

Every so often there are special opportunities. Swift represents a real chance to advance the state of common practice in our industry. [Swift isn't functional](/swift-is-not-functional), but it has a lot of very interesting pieces available. And Swift will be extremely popular, by luck of birth as much as anything. I don't mean to disparage the Swift dev team. They've done an admirable job. But if Swift weren't the language of iOS development, it would likely be a pretty minor thing. But since it's the favored language of an incredibly popular platform, and since it *does* have functional leanings, and frankly it's a pretty nice language to work in, it represents an incredible opportunity to positively impact a whole discipline.

To make the most of that opportunity takes live code in non-trivial apps, not just playing around with data structures and algorithms. Many of my code examples come out of a small [Wikipedia front-end](https://github.com/rnapier/WikipediaSearcher) I play with to see how these things might work in practice. I try to solve problems in a real (if small) iOS app and see where it takes me.[^production] This is the approach I recommend for any would-be FP evangelist. Build a real program with a real UI before forming too strong an opinion of what FP should look like in Swift. Engage with stdlib and Cocoa (and GCD, and Core Animation, and...), don't try to replace them. Don't assume stdlib is the way it is out of ignorance. Yes, it's backwards from Haskell. Yes, that makes certain kinds of composition really annoying. Maybe that just means those kinds of composition aren't going to be good Swift.

[^production]: I also apply some of these things to larger, more production apps, but I have to be more careful and don't have the time or risk tolerance to experiment as much. That's why I like having a non-trivial toy app.

{% pullquote %}

This doesn't stop Swift from enjoying great value from functional approaches. But it does mean that {" good functional approaches may look different from language to language "}, just like good OOP looks different from language to language. Haskell doesn't look like Lisp. Why should we expect Swift to look like Haskell?

{% endpullquote %}

Swift is like Scala. It consciously straddles two worlds. I think this should be celebrated. It means compromise, but I think it also means more users will get better software than if there were only "good languages" and "shipping languages." We really can have languages that give the benefits of tomorrow without losing all the working components of today. I think Swift can be one of those languages.

## The ties that >>=

I'm looking for help. I'm looking for FP veterans to bring what they've learned elsewhere, mix it with the experience of long-time Cocoa devs, and build a great foundation for Swift, maybe even nudge Apple in the process.

Much of that, I believe, is education. I have an [ongoing series here](/categories/functional). I'd love to learn to teach it more effectively.

It's also about good tools. The tools we use shape our thinking. I want it to be as easy as possible to write great code, and Swift has a few glaring omissions. To that end, I started a project called [LlamaKit](https://github.com/llamakit/llamakit), aimed at providing a small set of important tools that are easy to integrate into existing projects and should be nearly universally useful. There are much more full-lambda projects out there, particularly [TypeLift](https://github.com/typelift). LlamaKit isn't trying to fill that whole need, just provide the bare minimum to make functional programming approachable in Swift for common Cocoa problems, provide a foundation for more powerful frameworks, and help those frameworks interoperate more easily than they can today. I welcome input on the [mailing list](https://groups.google.com/forum/#!forum/llamakit). It's still early days for LlamaKit, but I think it will stabilize into something useful very soon.

## A slight nervousness around eagles

Occasionally, in my more self-aggrandizing moments, I fear I am Prometheus, stealing referential transparency from the gods to bring back to poor mortals trapped in their mutating loops. And I remember what came of Prometheus.

Then I remember I'm just a code monkey deep down, and it's all just code after all. I notice the paradigm is shifting. Seems a pretty nice time to light a fire.
