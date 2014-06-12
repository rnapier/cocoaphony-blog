---
layout: post
title: "Swift is not functional"
date: 2014-06-10 19:57:28 -0400
comments: true
categories: 
---

Ever since Swift came out, I keep seeing weird comments that Swift is a
functional programming language. I've puzzled a bit over why anyone would say
that, since there's really very little "functional" about Swift. It's a pretty
traditional object oriented language with a focus on generic programming.

My conjecture is that people are using a feature list to determine a
language's paradigm. But there's a reason we use the word *paradigm*.

> paradigm. (n) A worldview underlying the theories and methodology of a
> particular scientific subject

"A worldview." Yeah, that captures it.
<!-- more -->

Language paradigms are a lot like musical genres. They're messy things and we
can argue about where to draw the lines and what goes where and what's pure
and what's fusion. But classical guitar and heavy metal are different genres,
even if they both use guitars.

I have friends who say they have a very broad taste in music. They listen to
"everything." From Jimmy Buffet to Metallica, they love every kind of music
there is. Many programmers are the same way. They've only ever known the
procedural and object oriented paradigms. They think BASIC and Java are as
different as languages can get. When they encounter a new language, their
first question is "what's the syntax?" Their question should be "how does it
think about problems?"

*I'm going to say a lot about paradigms now. Like musical genres, there are
many opinions and ways of categorizing things. My way is not the only way. But
some ways are more useful than others. I'm saying that a taxonomy that groups
together Swift and Haskell because they have `map` is no more useful than
grouping Wangga, Opera, and Rock together because they have vocalists.*

Procedural (or imperative) programming is primarily concerned with decomposing
problems into a sequence of actions. Its usual structure is "do step one, then
repeat step two until something is true, then do step three." This paradigm is
so common in popular languages that many programmers think this is what it
*means* to program. It isn't. It's just one way to decompose problems. When
faced with a problem, the procedural question is "what steps do I need to
perform to solve this?"

Object-oriented programming is primarily concerned with decomposing problems
into a collection of self-contained objects with properties, and methods that
manipulate those properties. Its usual structure is a hierarchy of classes
with instances (objects) that inherit properties and methods. When faced with
a problem, the OOP question is "what kinds of objects need to work together to
solve this?"

Both of these ways of thinking are very, very common in popular programming
languages and work well together. Procedural programming has been with us
since the first machine languages. Even the early automated weaving machines
were working in a procedural paradigm.

OOP has dominated programming since the nineties. It's been the dominant
paradigm so long, and has dominated CS programs so long, that many programmers
think it's a given. They assume that only "ancient languages" like Fortran
lack objects (and even Fortran now has objects).

But OOP is just one way of thinking about problems. Functional programming is
a different way of thinking about problems. Functional programming is
primarily concerned with decomposing problems into functions that accept and
return immutable values. Its usual structure is a collection of functions that
transform values into other values, and various ways to combine functions. It
avoids mutable state and does not require that the evaluation of functions
occur in any particular order. Functional programming treats a program as a
math problem rather than a series of operations. When faced with a problem,
the functional question is "what kinds of values need to be transformed in
what ways to solve this?"

When you first started playing with Swift, what was the first thing you looked
for? Maybe how it handled classes and protocols? How to call methods, declare
and assign variables, define properties? Their version of `for` and
`while` loops? These are all OOP and procedural tools, and you were right to
think they would all be readily available and easy to use. You just needed to
know the syntax.

I'd heard people describing Swift as "functional," so when I pulled up my
first Swift workspace, I immediately looked for what Swift used for
`flatmap`.[^flatmap] I looked for how you split a list into head and tail. I looked
for a `foldLeft` equivalent and immutable collections. Swift didn't seem to
have special handling for any of them. It's not that a language *has* to have
these to be functional, any more than a language *has* to have a `for` loop to
be procedural. But if I showed you a new language and said it's procedural and
object oriented, but you have to implement `for` using `if` and `goto` and
there's no class inheritance, you might be...surprised at my feature choices.
A "functional" language that can't split a list into first and "not first"
elements trivially and in O(1) time is a very strange functional language.[^simple]

[^flatmap]: There is a flatmap, but it's explicitly only for Optionals, not a ubiquitous function like it is in most functional languages (where it is the heart of for-comprehensions and monads). Search the Swift header for "Haskell's fmap for Optionals."

[^simple]: I'm sure that all of these things will turn out to be fairly simple to do in Swift. But they don't jump out of the docs, and they weren't even discussed in any of the Swift videos. That's a measure of what's important versus what's possible. They tell you what paradigm you're in.

Yes, Swift has `reduce` and `map`. Yes, it has first-class functions and
pattern matching. And yes, these are features that are also commonly found in
functional languages. Its syntax even feels very similar to Scala (as soon as
I realized that associated values are case classes, everything about them made
sense). But it doesn't *think* like a functional language. They encourage you
to use `let` wherever possible, but you're always going to have a mix of `let`
and `var` in a Swift program, and most of the examples Apple gave included
variables. I almost never use mutable variables when I work in Scala. In
Haskell, mutable variables are considered advanced features that don't even
show up in intro books.

And that brings us to the real difference. In Swift, you fundamentally work in
a procedural/OOP paradigm, and the whole language is built around that. There
are some tools available to let you jump over to a functional style (without
the full power of functional programming) when it's useful. In Haskell, you
fundamentally work in a functional paradigm. There are some tools available
(monads) to let you jump over to a procedural style (without the full power of
procedural programming) when it's useful.

Some might say "Rob, you're being too literal. Swift is a *multi-paradigm*
language including OOP and functional." Nonsense. Scala is a multi-paradigm
OOP/functional language. When you approach a problem in Scala, you break it
into objects that work primarily on immutable data structures. That's what
OOP/functional looks like. They didn't even bother to provide an immutable
list in Swift. It's not that they can never add it; it's that it isn't
fundamental to the way Swift works.

Swift is a multi-paradigm, but it's not OOP/functional. It's OOP/generic.
Generic programming is primarily concerned with general purpose algorithms
that can be applied to arbitrary types. It has some similarities with
functional programming, and there are certainly languages that are both
functional and generic, but generic programming doesn't care if the algorithms
are functions (things that take and return immutable values) or processes
(things that mutate state). Swift isn't generic because it has `Array<Int>`.
You could implement that kind of structure in non-generic languages. Swift is
generic because you find generic programming all over the core library.
Consider functions like `advance`:

    /// Return the result of moving start by n positions.  If T models
    /// RandomAccessIndex, executes in O(1).  Otherwise, executes in
    /// O(abs(n)).  If T does not model BidirectionalIndex, requires that n
    /// is non-negative.
    func advance<T : ForwardIndex>(start: T, n: T.DistanceType) -> T

This is just the kind of function you'd expect in a generic language. It
encapsulates an algorithm that will work on anything that implements
`ForwardIndex`. It is not a method that instances of `ForwardIndex` inherit or
must implement. That seems subtle, but is actually a significantly different
way of thinking.

You see a lot of these in the Swift standard library, and they're the ones you
would expect to find in a generic language. A lot of things that look like
"functional" features are actually just generic algorithms. Look at
`quickSort` and `reduce`:

    func quickSort<C : MutableCollection where C.IndexType : SignedInteger>
      (inout elements: C, range: Range<C.IndexType>,
       less: (C.GeneratorType.Element, C.GeneratorType.Element) -> Bool)

    func reduce<S : Sequence, U>(sequence: S, initial: U, combine: (U, S.GeneratorType.Element) -> U) -> U

`reduce` is a very common functional tool, but it's right beside `quickSort`
which no functional language would expose this way (it mutates the
collection). Both are expressed in a generic style. They're just algorithms.
One happens to mutate, the other doesn't. What matters is that the algorithm
is reusable over many kinds of data, and that's generic programming. We get
some functional features, but it's a side effect, not the paradigm.

None of this is a critique of Swift. It's OK that it's not functional. I would
have loved all of Cocoa development to go functional, but just because I enjoy
it. I don't know if it would have furthered the goal of [really fantastic iOS and Mac apps](/week-of-swift/),
at least in the short term. It's not that
[FRP](https://github.com/ReactiveCocoa/ReactiveCocoa) isn't a good idea. I
don't have a strong opinion on that. It's just that the learning curve is high
for ObjC programmers compared to Swift.[^frp] And we'll need to integrate Swift
with (non-functional) ObjC for a long time.

[^frp]: My experience with reactive UI programming in Scala had mixed results. Even with a functional background, I found the learning curve to be high and programs very hard to debug. But it may just require more experience. It seems a great idea, I just don't know if it really is one.

My hope is that Swift will incorporate more functional features over time.
`if` and `switch` should return values. I should be able split a list into
head and tail in a pattern match (and this should be cheap). Functions should
accept a "tail recursive" attribute with mandatory tail-call optimization.
Mutating methods should be rare, and immutable data types should be plentiful.

None of these things will make Swift functional by themselves. But enough of
them could let us write in more functional patterns, and someday Swift and
Cocoa could actually become functional. And if that were the end result, then
Swift might be a surprisingly important language and could improve the
programming discipline because programmers would have to learn functional
programming to develop on a very popular platform. And learning functional
programming makes you a better programmer, even if you work in other
paradigms.[^motorcycle]

[^motorcycle]: I used to ride a motorcycle. When you're riding a motorcycle, you have to be much more aware than when you drive a car. If you're not, you're going to get hurt. But the thing I noticed was that riding a motorcycle made me a better car driver, too. Functional programming is like that. Riding a motorcycle isn't always the best way to get somewhere, but we'd have better drivers if everyone learned on motorcycles. We'd have better programmers if colleges taught Haskell first and Java later.

Or none of that may happen, and Swift might just be a language for writing
really fantastic iOS and Mac apps, and that's OK, too.
