---
layout: post
title: "Throw what don't throw"
comments: true
date: 2015-06-16 20:58
categories: 
---

So say you are trying out all this interesting new `throw` stuff in Swift 2. And
say you're running an early Beta in which many stdlib functions don't handle
throw closures yet. Or maybe you're in the future and dealing with some other
piece of code that you wish could handle a throw closure, but doesn't. What do
you do?
<!-- more -->

By now you may be asking "what the heck is a throw closure? Talk sense, man!"
Let's take a small step back and quickly introduce the new `throws` feature.
That's not the point of this article, though. You should go watch the WWDC
videos. But basically, it's like this. Say you have a function that might fail.
In Swift 2, you can write it this way:

```
enum Error: ErrorType { case Negative }

let f: (Int) throws -> String = {
    guard $0 >= 0 else { throw Error.Negative }
    return "".join(Repeat(count: $0, repeatedValue: "X"))
}
```

First, the `throws` in the signature tells us that this function may throw.
Functions may not throw errors unless they explicitly indicate that they can.

You might think of "throwing errors" as equivalent to "exceptions" in languages
you're familiar with, but it's a little different. A throw is really just a
fancy return. A throwing function can return *either* a type or an `ErrorType`.
And "throws" is probably best thought of as somewhat opaque sugar around an
Either type.

That tells us something very important:

> A function that throws errors is a different *type* than one that doesn't.

I don't mean that it's "some other kind of thing." I mean like `Int` is a
different type than `String`, and `String` is a different type than `(Int) ->
String`, `(Int) -> String` is a different type than `(Int) throws -> String`. In
fact, `(Int) -> String` is a *subtype* of `(Int) throws -> String`, which is
pretty awesome and a little subtle, but we'll get to that in another post.

So what does that mean? Let's think of a simple case of map today (Swift 2 Beta
1):

    print([1,2,3].map(f)) // Cannot invoke 'map' with an argument list of type '((Int) throws -> String)'

What's going on here? Let's look at the type signature:

    func map<T>(@noescape transform: (Self.Generator.Element) -> T) -> [T]

So `transform` is of type `(Element) -> T`. We're passing `(Element) throws ->
T`. Remember I said that a non-throwing function is a subtype of a throwing
function. So `(Element) throws -> T` is a *supertype* of what what this function
wants. That's like passing NSObject to something that wants UIView. You can't do
that.

So what do we do? Well for map, this is easy. We can just implement our own throwing version:

```
extension Array {
    func map<T>(@noescape transform: (Generator.Element) throws -> T) rethrows -> [T] {
        var result: [T] = []
        for x in self {
            result.append(try transform(x))
        }
        return result
    }
}
```

And now we can use it:

    print(try [1,2,3].map(f))

Notice the use of `try`. This is pretty different than how `try` is used in
other langauges, and another way that Swift's error handling doesn't quite match
"exceptions.") Swift uses `try` to remind the programmer about functions that
may throw errors. The compiler doesn't need `try`. It doesn't create scope, or
mark control flow points, or anything like that. It's not a function or a
constructor. It's just a keyword that Swift forces you to include so that *you*
(and your coworkers) remember what's going on. When you see `try`, you should
think "hey, control could suddenly jump somewhere else from this point." It
reduces surprise when that happens, and conversely tells you where control
*can't* suddenly jump (i.e. everywhere without `try`). I think that's pretty
nice.

You may also notice both `throws` and `rethrows` in the method signature. I'll
get to that in a later blog post. Just trust me for now. This code would also
work if you used `throws` in both places, but this is the better signature.

And one more "also notice." Also notice that this is an *overload* of map. The
closures have different types, so the compiler can pick the right one. Nice.

OK, that was a lot of setup, and you could probably figure out on your own how
to rewrite map this way. And besides, by beta 2, I'm sure threre will be a
proper (re)throwing version of map. So why bother? For the next step.

I know how map is implemented. It's really simple. But what if I *didn't* know
how it was implemented? How about some function that I'm not sure I could write
correctly? How about a more obscure function that may not get throwing love
quite so quickly? How about `Array.withUnsafeBufferPointer`? Ooohhh....

So here's our signature:

    func withUnsafeBufferPointer<R>(@noescape body: (UnsafeBufferPointer<T>) -> R) -> R

We want to accept a `body` that can throw, but we want to pass it to the
existing method, which can't accept a throwing closure. So what do we do? We go
back to our old friend, Result. Here's a super-simple Result implementation that
can convert to and from throwing closures:

```
enum Result<T> {
    case Success(T)
    case Failure(ErrorType)

    func value() throws -> T {
        switch self {
        case .Success(let value): return value
        case .Failure(let err): throw err
        }
    }

    init(@noescape f: () throws -> T) {
        do    { self = .Success(try f()) }
        catch { self = .Failure(error) }
    }
}
```

If you're familiar with Result or Either, this should be pretty self-evident,
but the key pieces are that `result.value()` will unwrap the result into either
a value or a thrown error. And `init` will take a throwing closure and convert
it into a Result. With that piece, here's how we build our method:

```
extension Array {
    func withUnsafeBufferPointer<R>(@noescape body: (UnsafeBufferPointer<T>) throws -> R) throws -> R {
        return try self.withUnsafeBufferPointer { buf in
            return Result{ try body(buf) }
            }.value()
    }
}
```

The closure `body` is of type `(UnsafeBufferPointer<T>) throws -> R`, which we
can't pass to `withUnsafeBufferPointer`. But *our* closure is of type
`(UnsafeBufferPointer<T>) -> Result<R>`, which is just fine (no throws here,
move along).

Let's walk through the closure from the inside out.

1. `try body(buf)`. Execute our throwing closure using the `buf` provided to us by the default implementation.
2. `Result{...}`. Capture it into a Result enum
3. `return Result{...}`. Return the Result, not the underlying value.
4. The whole function nows looks like `return try result.value()`
5. This either returns the computed value (type `R`), or throws

This method is marked `throws` rather than `rethrows` because ... reasons. (The
final throw doesn't come directly from `body`, but from `value()`. That'll
hopefully make more sense when I explain `rethrows`.)

And just for completeness (and because I needed it myself), we can do the same
thing to `withUnsafeMutableBufferPointer`, but we need to give the compiler more
type information because of the `inout` parameter:

```
extension Array {
    mutating func withUnsafeMutableBufferPointer<R>(@noescape body: (inout UnsafeMutableBufferPointer<T>) throws -> R) throws-> R {
        return try self.withUnsafeMutableBufferPointer { (inout buf: UnsafeMutableBufferPointer<T>) in
            return Result{try body(&buf)}}.value()
    }
}
```

These particular implementations probably won't be useful for long. I'm sure the
stdlib team will quickly clean this up (and you probably shouldn't be using
`withUnsafeBufferPointer` very much anyway). But hopefully exploring how this
works can give some insight into Swift's new error handling system. Result isn't
dead; it still has interesting use cases like this one. But I expect those use
cases to shrink, and I highly recommend exploring the new error handling and
discover how to build great things with it.
