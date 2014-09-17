---
layout: post
title: "I, for one, welcome our new Haskell overlords"
date: 2014-08-31 22:25:13 -0400
comments: true
categories: 
published: false
---

I was half-way through two different blog posts, uncertain which to do next,
along with all this exploratory work in how I think Futures and Promises might
work best in Swift, and I was suddenly brought back to a topic I've been mulling
over for weeks. @TacticalGrace made a comment that reminded me of it.

> By not using standard FP terminology in emerging languages like Swift, we deny
> learners access to a lot of existing literature.

I couldn't agree more. But there's a lot more to it, and frankly, I need to ask
the FP community to step up a little more to plate here.

<!-- more -->

## Objective History

I remember when OOP became a thing in the 90s. I'd been a professional developer
for about a decade at that point, shipping products in QuickBASIC, FoxPro,
dBase, C, and SL-1 (a phone switching language so obscure it doesn't even have a
Wikipedia page). I'd done hobby work in Pascal, various kinds of assembler, and
even LISP. But the closest I came to OOP were some toy projects in Borland's
Object Windows Library for Turbo Pascal.

This isn't to brag about my old-school hipsterness. If you know me, you know I
don't have much of that. My point is that it wasn't that long ago that you could
do a lot of professional work and never talk about objects, classes, properties,
methods, or any other OOPishnesses.

Then suddenly, Java, and good grief, how could you possibly be a real programmer
if you couldn't abstract factory your instance interface? Java didn't invent
OOP. Far from it. But suddenly OOP mattered to everyone.

>First they ignore you, then they laugh at you, then they fight you, then you
>win. -- Mahatma Gandhi

I remember vividly people laughing at OOP. It was too academic. Too abstract.
Too bloated. Too impractical. Too trendy to last. But here we are, maybe 15
years later, and OOP is just how programming is done. When I introduce people to
Go, I always have to explain early and repeat often that Go is not an object-
oriented language. That always confuses people.

Don't get me wrong. Most developers do OOP terribly. Really, really terribly.
They keep making horrible design mistakes that we've known for decades are
horrible design mistakes. But OOP is how you do things. It's the paradigm in
which both good and terrible choices are made today. It wasn't always that way.

## Rise of the Lambdas

When I look around at FP today, I see OOP in the 90s. FP keeps creeping into
languages. Python, Ruby, JavaScript, C#, and Java didn't start out intentionally
functional, but keep picking up functional features. New languages like Swift
and Rust self-consciously flirt with functional programming, even if they won't
quite commit to it.[^go] Microsoft is pushing F#. Twitter is working in Scala.
FP is becoming part of the landscape. Words like *closure* and *comprehension*
are invading the vocabulary of professional developers. We've been here before.

[^go]: Go is a maverick here, self-consciously *excluding* a lot of functional programming features, with the exception of first-class functions. Go also excluded a lot of OOP features. Go excluded a lot of features in general. That's probably its biggest feature. That and goroutines.

