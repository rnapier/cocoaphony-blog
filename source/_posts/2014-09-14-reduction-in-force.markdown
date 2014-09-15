---
layout: post
title: "Reduction in force"
comments: true
date: 2014-09-14 20:14
categories: swift functional
---

Our last [talk about >>==](/flatmap) was full of twists and turns, some
philosophy, surprising connections, and a radical new operator. It was a lot to
absorb, and you may have to play with it some in your own code before you really
know what it's about. That's ok.

Let's take a little break and talk about a handy functional tool built into
Swift stdlib. I promise no big reveals, no new operators, no fancy types; just
hands-on, practical discussion of the Swiss Army knife of transform functions:
`reduce`.

<!-- more -->

Reducing is almost easier to show than to explain. Let's start with a trivial
example. You have an array of numbers and you want to know the sum. We might say
you want to "reduce" a `[Int]` to a single `Int`. `reduce` takes a sequence, an
intial value, and a "combining" function like this:

    let xs = [1,2,3,4,5]
    let sum = reduce(xs, 0) { accumulator, value in accumulator + value }
    // ==> 15

The most interesting part is the combining function. It is passed a "value so
far" and a "next value from the list" and it needs to return the result of
combining them. Its signature looks like this:

    (U, T) -> U

So it doesn't have to return the same kind of thing as is in the list, but it
often does. In our example, since we want the sum, we just add the two values.
We could just as easily reduce the list to its product:

    let product = reduce(xs, 1) { accumulator, value in accumulator * value }
    // ==> 120

I'm spelling out parameters to make it clear exactly what is being passed to
the combining function, but we can of course use Swift shortcuts for this:

    let sum = reduce(xs, 0) { $0 + $1 }

Or we can go futher, and shorten it to:

    let sum = reduce(xs, 0, +)

What's up with that? [I told you before](/flatmap), `+` is just a function:

    func +(lhs: Float, rhs: Float) -> Float

And it's in the form `(T, T) -> T`, which is just a special case of `(U, T) ->
U`. So that's fine, and we can pass it as the combining function.

There's also a method form that can be convenient:

    let sum = xs.reduce(0, combine: +)

We can think of that as "take the list of x values, and add them, starting with
zero."


### A note on origami and names

Another common name for this function is "fold." Sometimes, in other languages,
you'll see "fold left" or "fold right." Swift's "reduce" is the same as "fold
left." (A right fold starts at the end of the list and goes backwards.) You may
also see it called "aggregate" or "accumulate." They're all pretty much the same
function.

## Finding a starting point

OK, so we can add and multiply stuff. What else you got? We can get minimums and
maximums. Let's implement stdlib's `minElement` for arrays with
`reduce`.[^array]

[^array]: In this post, and in many of my posts, I will focus on Array implementations rather than the more general Sequence. That's because Sequence (and Collection) can introduce a lot of complexity and obscure the key points being discussed. Some of their complexity is due to the nature of type constraints, and some is due to quirks about Swift that will likely improve. I've chosen to dodge all of that and focus on the most common and simplest case: Arrays.

Reducing requires an initial value. So, what should it be? For types that have a
known minimum (like `Int.min`), you might be tempted to use it. But that's not
very flexible, and some orderable types don't have an obvious minimum. For
example, what if we implemened a `BigNum` type that supported arbitrarily large
or small values?

A common solution is to treat the first element as the initial value, and then
reduce the rest:

    func minElement<T: Comparable>(xs: [T]) -> T {
      return dropFirst(xs).reduce(xs[0], combine: min)
    }

That's a reusable pattern, so we could, if we wanted to, extract it:

```
extension Array {
  func reduce1(combine: (T, T) -> T) -> T {
    return dropFirst(self).reduce(self[0], combine: combine)
  }
}

func minElement<T: Comparable>(xs: [T]) -> T {
  return xs.reduce1(min)
}
```

Notice that `reduce1` requires a combining function that takes and returns the
same type. It's worth taking a moment and thinking about why that has to be
true.

Of course, `reduce1` crashes if the array is empty. What if we wanted to get
back an `Int?` to guard against that? Here's one way we could do it:

    func safeMinElement<T: Comparable>(xs: [T]) -> T? {
      return xs.reduce(nil) { m, x in min(m ?? x, x) }
    }

So we start with `nil`, and for each element if the current minimum is `nil`, we
take whatever was passed in, and otherwise we take the minimum. Notice how we
rely on Swift's habit of promiting anything into an optional when required.
Let's us be pretty <strike>sloppy</strike> expressive.

## Beyond math

The combining function `(U, T) -> U` says nothing about numbers. We can reduce
anything we can imagine. We could join strings just as easily.

    func join(elements: [String]) -> String {
      return elements.reduce("", +)
    }

Or, [as promised](/flatmap#fn:1), here's `flatten`, which takes a nested array
and removes one level of structure:

    func flatten<T>(xs: [[T]]) -> [T] {
      return xs.reduce([], +)
    }

Told you it was simple. Notice how summing numbers, joining strings, and
flattening arrays all have the same implementation, differing only in their
initial value? That's another thing worth thinking about for a while, but it's
too much theory for this post. (If you want to research it, the magic search
term you want is *monoid*.)

Mapping an array is just a special case of reducing:[^leftright]

    func map<T, U>(xs: [T], f: T -> U) -> [U] {
      return xs.reduce([]) { $0 + [f($1)] }
    }

[^leftright]: If you're familiar with Haskell, you may know that `map` is usually implemented as a `foldr`, while this is a `foldl`. That's just for performance. In Haskell, list prepending (`:`) is much faster than appending (`++`). In Swift, array appending is the faster operation. So `foldr` is common in Haskell, but isn't even in Swift stdlib. Keep this in mind when translating Haskell algorithms to Swift. Haskell often walks lists backwards for performance reasons. It's more natural in Swift to walk them forward.

So is filtering:

    func filter<T>(xs: [T], includeElement: T -> Bool) -> [T] {
      return xs.reduce([]) { filtered, x in includeElement(x) ? filtered + [x] : filtered }
    }

FlatMap:

    func flatMap<T, U>(xs: [T], f: T -> [U]) -> [U] {
      return xs.reduce([]) { $0 + f($1) }
    }

Reverse:

    func reverse<T>(xs: [T]) -> [T] {
      return reduce(xs, []) { [$1] + $0 }
    }

Even counting!

    func countElements<T>(xs: [T]) -> Int {
      return reduce(xs, 0) { c, _ in c + 1 }
    }

You can do a lot of stuff this way. It's particularly useful when you find
yourself declaring a `var` just so you can initialize it with a loop. Any time
you find yourself using `var` inside a function, consider whether this is better
done with something else (`map`, `filter`, `reduce`, etc). Usually the answer is
yes.

## From whence would you return?

How about `contains`?

    func contains<T: Equatable>(xs: [T], find: T) -> Bool {
      return xs.reduce(false) { found, x in found || find == x }
    }

Hmmm.... It works, but it's a poor choice in my opinion. `reduce` computes over
the full list, so this is wasting a lot of effort checking values that aren't
needed. A good way to think about it is how you would expect this function to
behave if the sequence were infinite. If you would never expect the function to
return (like for `sum`), then `reduce` is proably a good fit. If you might
expect it to return anyway (like for `contains`), then `reduce` is probably the
wrong tool.

Another good way to think about it is whether you would include a `return` or
`break` in your for-loop (or just use a while-loop). If so, your problem
probably doesn't match `reduce` well.

To make it more clear, let's see how `reduce` can be implemented:

```
func reduce<T, U>(xs: [T], initial: U, combine: (U, T) -> U) -> U {
  var result = initial
  for x in xs {
    result = combine(result, x)
  }
  return result
}
```

If your problem can be "reduced" to this, then `reduce` may be a good choice. If
you need to stop the for-in loop, then you'll probably want another tool like
`find`.

## So doctor, should I reduce?

I've given a bunch of examples here to show how powerful and flexible `reduce`
is. I want to get your imagination going a little bit and give you some ideas on
how to use this function to solve a wide range of problem. But just because you
*can* write `map` in terms of `reduce` doesn't mean you *should*.

Most of the time if your result is an array, mapping and filtering are the right
tools. If you're taking an array and deriving a single value, then `reduce` (or
`find`) is often the best tool. But if you have a complex combination of mapping
and filtering, then a single `reduce` may simplify that and also speed it up.

Reducing is a quite popular operation in functional languages. In fact, a lot of
people (including your humble author) spend a lot of time trying to solve
complicated problems with a single, elegant reduce. When I started this blog
post, I got about half-way through implementing sorting that way when I realized
I needed to stop. Reduce is the kind of function that makes people try to be
clever, much like regular expressions. Resist the temptation, at least in your
production code. Use the tools that make your code clear, not the tools that
make you look smart.

But with that in mind, reduce your problems away!
