---
layout: post
title: "Your lips keep moving, but all I hear is \"applicator functive monastic llama calculus...\""
date: 2014-08-09 16:16:19 -0400
comments: true
categories: 
---
\...and I hated calculus.

Yes, the functional world seems to overflow with bizarre terms that defy
intuition. Faced with words like *object*, *property*, *inherit*, *class*, even 
non-programmers can get some handle on what they might mean. *Applicative
functor* is not so kind. Nor is the ubiquitous *monad*, a word that feels
designed to obscure its meaning (plus the ensuing 
[arguments over whether something is really a monad or a monoid](http://www.haskell.org/pipermail/haskell-cafe/2009-January/053317.html)).

Let me boil functional programming down to its basics, the part you need before
we can really get started: variables are evil. Stop mutating them. It just makes
them more evil. If I could do just one thing to improve your Swift programs, it
would be to generate an electric keyboard shock every time you typed `v` `a`
`r`. Yeah, you'll need it sometimes, but each time you should ask "is it worth
the shock?" And by "the shock," I mean "hard to find bugs."[^computed]

[^computed]: Swift unfortunately overloads `var` to mean both "mutable" and "computed property" even if the computed property is immutable. I am only referring to the first use.

We inherit a very unfortunate piece of syntax from the earliest days of FORTRAN.
It's so common that you've probably never considered how insane it is. Here it
is in Swift:

    var x: Int
    x = 5
    x = 7

This program makes no sense. Read it out loud the way we usually do. "X is an
Int." Good. "X equals five." Cool, got it. "X equals seven." What? Didn't you
just say it equals five? Does 5 equal 7? What are you trying to pull here? The
more reasonable result of this program should be `undefined` or possibly
`false`. Both of these statements cannot be true. Yet we write this kind of
stuff all the time and we expect it to mean something other than "equals."

The correct way to read this out loud is "assign five to *x*, then assign seven
to *x*."[^algol]

I know that sounds pedantic. A lot of the build-up to functional programming
sounds pedantic, but bear with me. I'm going to keep bringing it back to
problems we all face every day, in mostly the terms we're all used to.

[^algol]: ALGOL, and later Pascal, got this at least half-right: `x := 5`. There wasn't a `<` key on early keyboards, so `:` had to do. This really should be written `5 -> x`, since the assignment happens after evaluation, but at least "x receives 5" is more sensible than "x equals 5." So many C bugs could have been avoided if it had used ALGOL syntax. It amazes me that Swift held onto `=` for assignment.

Let's compare this to another piece of Swift:

    let x = 5

Here, the `=` is fundamentally different (and so should really have a different
operator). This doesn't say "assign 5 to x." This says "x *is* 5" and
equivalently, "5 *is* x." They are just different names for the same thing.
Anywhere in this scope that you encounter *x*, the compiler may replace it with
5 and vice versa. This is the equals sign that you learned in elementary school
arithmetic. It says these two things are the same. In your first Algebra class,
you learned how to use this equivalence to solve problems. But somewhere along
the way (well, in FORTRAN), we merged this simple and powerful idea into a much
more complicated, but less general, idea: assignment.

Assignment is complicated because it creates state. The world is different
before the assignment than after the assignment. State makes it hard to know
exactly what a function will do. It makes it hard to test. And the broader the
state, the more confusing it gets. A local variable defined three lines above
doesn't create a lot of state to juggle. An instance variable that may change
from call to call can be tricky. A global variable that may be set on any thread
at any time is a nightmare.

{% pullquote %}

Much of our job as programmers is to reason about programs. This word, *reason*,
comes up a lot in academic discussions, but I don't think we use it as much as
we should in the code mines. {" Fixing bugs is fundamentally about
distinguishing between what *should be* and what *is*. "} Both of these require
reasoning about your code. Given a function, what are its inputs and outputs?
What is it *supposed* to do? What does it *actually* do?

{% endpullquote %}

Perhaps the most overlooked part of that process is "what are its inputs and
outputs?" It's really the question "what things could *possibly* be breaking
this, and what other things could this *possibly* be breaking." And this is where
state comes in. Consider a method:

    class RestaurantMeal {
        ...
        func calculateTheBill() { ... }
    }

This is pure OOP. The object has some state. I ask the object to mutate itself.
Later, I'll ask the object for its new state. All the details, including what
goes into the bill, are encapsulated in the object and are hidden from the
caller.

It's very simple, but consider how hard it is to reason about this method. What
are its inputs and outputs? Well, in principle, the entire current state of the
object is the input, and the entire mutated state of the object is the
output.[^globals] What test cases would you write? And if the implementation
details changed, would those test cases still provide sufficient coverage? If my
final bill is wrong, how I do reproduce the state of this object to debug it?
The whole point of OOP is that the internal details of `calculateTheBill()` are
private. But in the real world of testing and debugging, they often turn out to
be very important because we have to recreate the relevant state.

[^globals]: For this discussion, assume there are no mutable globals or singletons (which are just globals by another name). If there were, they create the same problems for every approach.

Now consider the following free function (i.e. not part of an object):

    func totalCostForItems(items: [Double], taxRate: Double) -> Double { ... }

You pass data to a function, and it returns you data. There is no state. If you
pass the same values, you will always get the same result. All of the inputs and
outputs are obvious and knowable from the code (unlike documentation, which can
become out of date). Internal changes cannot change whether the tests are
sufficient. If there are new inputs or outputs, the public signature has to
reflect them. There are no external concurrency concerns. You can compute the
result on as many queues as you like. You know that none of your inputs can
change behind your back. You don't have to worry about whether your parameters
are thread-safe because you have your own, immutable copies.

`calculateTheBill()` *assigns*. `totalCostForItems(taxRate:)` *is*. This is a
pure functional approach to the problem.

"Functional? But there's not a single `map` or closure or `<*>` to be seen.
Wasn't the point of [Swift is not Functional](/swift-is-not-functional) that
just using a few functions doesn't make a language functional? Isn't this
all possible in C?"

All true. The point here isn't to lay out the entirety of functional
programming. It's to capture the first intuitions about mutable state, and why
even programmers with no interest in CS theory might want to minimize it. It's a
way of thinking about the problem rather than a particular set of features. I'll
discuss more in later posts.

In the earliest FORTRAN programs, mutable state was already a regular source of
bugs. Today we have highly concurrent apps with dynamic user interfaces and
things have only gotten worse. Programs have gotten bigger, more complicated,
and harder to get right. That means long hours of difficult testing, frustrating
debugging, missed ship dates, and hard-to-reproduce bug reports from your
customers. Excessive state is a major contributor.

Totally eliminating state from your programs is challenging at best, counter-productive 
at worst. But as we go along in this series, I hope you start to see why you'd
want to treat state as a powerful and somewhat dangerous tool to be used in
moderation. And the first step down that road is to stop typing `var` (ouch!)
