---
layout: post
title: "I, for one, welcome our new Haskell overlords"
date: 2014-08-31 22:25:13 -0400
comments: true
categories: 
published: false
---

I was half-way through two different blog posts, uncertain which to do next, along with all this exploratory work in how I think Futures might work best in Swift, and I was suddenly brought back to a topic I've been mulling over for weeks. [Manuel Chakravarty](https://twitter.com/TacticalGrace) made a comment that reminded me of it. (Will all my blog posts start with some comment from @TacticalGrace?)

> By not using standard FP terminology in emerging languages like Swift, we deny learners access to a lot of existing literature.

I couldn't agree more. But there's a lot more to it, and I hope the FP community will get involved in ways they may not be used to. We'll get there. First, a little history for the rest of us. FP folks, I'll get back to you in a couple of sections.

<!-- more -->

## Objective History

I remember when OOP became a thing in the 90s. I'd been a professional developer for about a decade at that point, shipping products in QuickBASIC, FoxPro, dBase, C, and SL-1 (a phone switching language so obscure it doesn't even have a Wikipedia page). I'd done hobby work in Pascal, various kinds of assembler, and even LISP. But the closest I came to OOP were some toy projects in Borland's Object Windows Library for Turbo Pascal.

This isn't to brag about my old-school hipsterness. If you know me, you know I don't have much of that. My point is that it wasn't so long ago that you could do a lot of professional work and never talk about objects, classes, properties, methods, or any other OOPishnesses.

Then suddenly, Java, and good grief, how could you possibly be a real programmer if you couldn't abstract factory your instance interface? Java didn't invent OOP. Far from it. But suddenly OOP seriously mattered.

>First they ignore you, then they laugh at you, then they fight you, then you win. -- Mahatma Gandhi

I remember vividly people laughing at OOP. It was too academic. Too abstract. Too bloated. Too impractical. Too trendy to last. But here we are, maybe 15 years later, and OOP is just how programming is done. When I introduce people to Go, I always have to explain early and repeat often that [Go is not really an object-oriented language](http://golang.org/doc/faq#Is_Go_an_object-oriented_language). That always confuses folks.

Don't get me wrong. Most developers do OOP terribly. Really, really terribly. They keep making horrible design mistakes that we've known for decades are horrible design mistakes. But OOP is how you do things. It's the paradigm in which terrible choices are made today. And good choices too. It's just how things are done. It wasn't always that way.

## Rise of the Lambdas

{% pullquote %}

When I look around at FP today, I see OOP in the 90s. FP keeps creeping into languages. Python, Ruby, JavaScript, C#, Java. They didn't start out intentionally functional, but they keep picking up functional features. New languages like Swift and Rust self-consciously flirt with functional programming, even if they won't quite commit to it.[^go] Microsoft is pushing F#. Twitter is working in Scala. FP is becoming part of the landscape. Words like *closure* and *comprehension* are invading the vocabulary of professional developers. This has all happened before. This will all happen again. {" A paradigm is sneaking in when you aren't paying attention. Pay attention. "} There's a chance here to influence development practice for decades.

[^go]: Go is a maverick here, self-consciously *excluding* a lot of functional programming features, other than first-class functions. Go also excluded a lot of OOP features. Go excluded a lot of features in general. That's probably its biggest feature. That and goroutines.

{% endpullquote %}

## Please Don't Applicative Functor the Semi-Group

What's a biscuit joiner?
: It's a machine for extracting parallel planes comprising half of a negative ovaloid prism.

What's a monad?
: It's an endofunctor with two natural transformations satisfying associativity and identity.

Let's try that again....

What's a biscuit joiner?
: It's a tool for cutting slots in the edges of boards. You put a little piece of wood in there (called a "biscuit") so you can glue panels together, like for a tabletop or door.

What's a monad?
: It's a result in a box. You can use them to chain together operations that might fail, or might happen in the future, or otherwise have some "context" around them that you want to pass along with the result itself. A Swift optional is one kind of monad, where the "context" is whether it actually has a value or not.

None of the definitions above are complete or fully correct. But the last two are *useful* for people likely to be asking those questions. After reading the second definition of a biscuit joiner, I wouldn't expect you to be able to even recognize one, let alone use it safely, but you'd at least know when you might want to find out more about it.

The same is true for how we introduce FP concepts. We need not to be afraid of metaphor, even bad metaphor. I'm looking to people more expert than I am for better metaphors; better starting points. Maybe my monad intro could be improved. I'm aware that it doesn't perfectly explain why lists are also monads. But starting the discussion with monoids and the monadic laws closes the conversation. It says this is something unrelated to shipping products. It shouldn't be in the first paragraph, let alone the first sentence. It's better to start a bit wrong and build on that, than to start more correct (but still a little wrong) and make an important concept seem irrelevant.

I'm not saying we shouldn't use FP terms, even the opaque terms of art that have come from category theory. I agree with what @TacticalGrace was saying at the start of this. I'm just saying we should introduce them from in ways that engage the goal, which is great shipping software, not great category theory.

There is so much we can use well without fully understanding. Carpenters do not have to learn plant biology, let alone the subatomic nature of matter, before they can learn to work with and against the grain. I'd rather a great carpenter build my house than a great materials scientist. To ship great products, I want a programmer, not a mathematician.

I want more people turning FP concepts into JSON parsers tied to REST clients with local databases and UI animations built on popular frameworks. We need FP experts engaging with the existing platforms, not trying to replace them with Haskell. [Ship you a Haskell](http://robots.thoughtbot.com/ship-you-a-haskell) is a great article, but most of us work on platforms for which shipping is assumed, not news. "Employs total referential transparency" isn't particularly useful for my AppStore blurb if the program is late and the animations are glitchy. FP is a means to an end for most developers, not the end itself.

To those of you who don't know Haskell, I'm still telling you to go learn it. It's worth it. I just noticed that Apple's job descriptions for the Foundation team include "Knowledge of Haskell, Rust, F#, or similar languages will be useful." But things that make sense in Haskell don't make sense everywhere. Haskell is just a language. Ubiquitous laziness and currying were choices of one language, not the one true functional way. They introduce tradeoffs.[^lazy] Languages that chose other tradeoffs need their own functional idioms. We shouldn't write JavaScript in Swift (seriously, stop it), or Haskell in Swift, or ML in Swift, or even Objective-C in Swift. We must find our way to write great Swift on its own terms. We should learn from our ancestors, not just relive their lives.

[^lazy]: Swift's initial attempt at making things lazy by default was a disaster IMO. I'm glad they abandoned that. It just didn't work with the rest of Cocoa.

## Swift is a Special Flower

Every so often there are special opportunities. Swift represents a real chance to advance the state of common practice in our industry. [Swift isn't functional](/swift-is-not-functional), but it has a lot of very interesting pieces available. And Swift will be extremely popular, by luck of birth as much as anything. I don't mean to disparage the Swift dev team. They've done an admirable job. But if Swift weren't the language of iOS development, it would likely be irrelevant. But since it's the favored language of an incredibly popular platform, and since it *does* have functional leanings, it represents an incredible opportunity to positively impact a whole discipline.

To make the most of that opportunity takes live code in non-trivial apps. Many of my code examples come out of a small [Wikipedia front-end](https://github.com/rnapier/WikipediaSearcher) I play with to see how these things might work in practice. I try to solve problems in a real (if small) iOS app and see where it takes me. This is the approach I recommend for any would-be FP evangelist. Build a real program with a real UI before forming too strong an opinion of what FP should look like in Swift. Engage with stdlib and Cocoa, don't try to replace them. Don't assume stdlib is the way it is out of ignorance. Yes, it's backwards from Haskell. Yes, that makes certain kinds of composition really annoying. Maybe that just means those kinds of composition aren't going to be good Swift.

Some concrete points:

* Swift prefers methods over free functions. (This is not a guess. I asked.) Methods auto-complete better and make it easier to discover what a class can do. I am aware (and I'm certain the Swift team is even more aware) of the limitations of methods vs. functions for composition. Swift still prefers methods. There are a lot of limitations on using generics with methods right now. You should expect this to improve rather than for Swift to become more function-centric.

* Swift is operator-light. This goes with preferring methods to free functions. Only punctuation operators are allowed to be infix functions. Punctuation operators introduce a high learning curve when encountering new code. Not all Haskell operators are legal and available in Swift (most critically `<$>` and `>>=`), so introducing operators for those means inventing something unknown to anyone (and *everyone* has picked a different set of replacements).[^bind] The Swift compiler currently has explosive performance behavior on some operators, [particularly `|>`](https://gist.github.com/rnapier/58bb75ac1c67cd5775fc). Operator precedence and associativity are defined globally, opening the opportunity for collisions if frameworks choose different operators. My point is that I think we should go slow with operators and be hesitant to add an operator unless it demonstrates great benefit to Cocoa patterns.

[^bind]: My personal preferences are `<^>` and `>>==`.

* Swift likes its closures at the end. This matches how ObjC typically does things, and coupled with "last closure outside the parens" can, used carefully, lead to some very nice constructs that are easy to read for Cocoa programmers, even if it's not as composable as currying. Work with this, not against it.

* Swift uses ARC. Circular references are a royal pain in ARC. That means some data structures aren't going to port from garbage collected systems. Don't force them. Rethink them.

* Swift likes Cocoa, GCD, Core Data, Core Animation, etc. It seems obvious that the platform will adapt more to Swift idioms, but you should expect Swift to continue to be tightly bound to Cocoa for (at least) the foreseeable future. You should embrace that, not fight it. If Cocoa already does something, make sure to integrate easily with it.

None of these points stop Swift from enjoying great value from functional approaches. But they do mean that good functional approaches may be different in Swift than in other languages. How to best implement OOP varies too. Arguably JavaScript's prototype system is closer to the original OOP concept than C++ or Java. Objective-C made significant changes on how SmallTalk expressed OOP. You can write good OOP in ObjC and you can write good OOP in Java. But if you write Java in ObjC, it'll be bad code. The same is true for Haskell (or ML or Lisp or Erlang) and Swift.

Swift is like Scala. It consciously straddles two worlds. I think this should be celebrated. It means compromise, but I think it also means more users will get better software than if there were only "good languages" and "shipping languages." We really can have languages that give the benefits of tomorrow without losing all the working components of today.

## The ties that >>=

I'm looking for help. I'm looking for FP veterans to bring what they've learned elsewhere, mix it with the experience of long-time Cocoa devs, and build a great foundation for Swift, maybe even nudge Apple in the process.

Much of that, I believe, is education. I have an [ongoing series here](http://robnapier.net/blog/categories/functional). I'd love to learn to teach it more effectively from those who have taught this much longer than I have.

It's also about good tools. The tools we use shape our thinking. I want it to be easy as possible to write great code, and Swift has a few glaring omissions. To that end, I started a project called [LlamaKit](https://github.com/llamakit/llamakit), aimed at providing a small set of important tools that are easy to integrate into existing projects. There are much more full-lambda projects out there, particularly [TypeLift](https://github.com/typelift). LlamaKit isn't trying to fill that whole need, just provide the bare minimum to make functional programming approachable in Swift for common Cocoa problems, and to help other libraries to interoperate more easily than they can today. I welcome input on the [mailing list](https://groups.google.com/forum/#!forum/llamakit).

## A slight nervousness around eagles

Occasionally, in my more self-aggrandizing moments, I fear I am Prometheus, stealing referential transparency from the gods to bring back to poor mortals trapped in their mutating loops. And I remember what came of Prometheus.

Then I remember I'm just a code monkey deep down, and it's all just code after all. I notice the paradigm is shifting. Seems a pretty nice time to light a fire.
