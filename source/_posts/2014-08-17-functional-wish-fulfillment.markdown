---
layout: post
title: "Functional Wish Fulfillment"
date: 2014-08-18 22:00:00 -0400
comments: true
categories: swift functional
---

Yes, this is another of those "how to parse JSON in Swift" blog posts that seem
to be required of every Swift blogger. And yes, several of the techniques we'll
work through come from the functional programming world. And, *yes*,
Swift+Functional+JSON is itself a well-worn trail. But still, I hope you find
this exploration helpful. Don't think of it as functional programming. Think of
it as the path of "I wish there were a function that...."

<!-- more -->

Let's start with the setup. We want to build a nice Wikipedia front end, so step
one is to allow the user to type in some search term, and return a list of
pages. Our input is a piece of JSON like this from the Wikipedia API (after
searching for "a"):

    ["a",["Animal","Association football","Arthropod","Australia","AllMusic",...]]

Our output should be a list of pages or an error. "A list of pages or an error."
That's kind of a funny thing. What type would that be? If you're an old ObjC dev
like me, then you'd probably think (in Swift):

    struct Page { let title: String }
    func pagesFromData(data: NSData, error: NSErrorPointer) -> [Page]?

But that's kind of a pain to use. We have to create an `NSError` variable and
pass it with `&error` and then check whether there was a result. Bleh. Gotta be
a better way in this new Swift world.

Let's say it again. "A list of pages or an error." That means it's something
that could be one of a couple of types. That's just an enum. Let's make it:

```
enum PageListResult {
  case Success([Page])
  case Failure(NSError)
}
```

*I'm going to assume that you've already seen enums with associated values and
you understand the above type. If you don't, stop here and go read the
"Associated Values" section of "Enumerations" from
[The Swift Programming Language](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/Enumerations.html).
This is a really important concept in Swift. Seriously, go read it. It's like
two pages long and we're going to use it a lot. Don't worry. We'll wait for
you.*

So that gives us a much better function signature:

    func pagesFromData(data: NSData) -> PageListResult

I'm amazed how often just figuring out the type I want and the function
signature really simplifies everything else. You may be familiar with this
approach from TDD, but to me, it's WDD: Wish Driven Development. "I wish there
were a function that would take data and return me a list of pages or an error."

A very interesting thing happened when we phrased the wish this way. The "happy
path" and the "error path" are now the same path. For every possible input,
there is a result. It might be an error, but an error is just a kind of result.
That seems kind of nice.

Anyway, back to our wish fulfillment. We wished that there were this function,
so let's get to work writing it. (In software, we are our own genies.) To parse
this data, we need to do several things, any of which could fail:

1. Parse the `NSData` into a JSON object
1. Make sure the JSON object is an array
1. Get the second element
1. Make sure the second element is a list of strings
1. Convert those strings into pages

If we write this in a straightforward style, we get the following
([complete gist](https://gist.github.com/rnapier/9e8f92a1ce6be5c3d295)):

```
typealias JSON = AnyObject
typealias JSONArray = [JSON]
struct Page { let title: String }

func pagesFromData(data: NSData) -> PageListResult {

  // 1. Parse the NSData into a JSON object
  var error: NSError?
  let json: JSON? = NSJSONSerialization.JSONObjectWithData(data,
                      options: NSJSONReadingOptions(0), error: &error)

  if let json: JSON = json {

    // 2. Make sure the JSON object is an array
    if let array = json as? JSONArray {

      // 3. Get the second element
      if array.count < 2 {
        // Failure leg for 3
        return .Failure(NSError(localizedDescription: "Could not get second element. Got: \(array.count)"))
      }
      let element: JSON = array[1]

      // 4. Make sure the second element is a list of strings
      if let titles = element as? [String] {

        // 5. Convert those strings into pages
        return .Success(titles.map { Page(title: $0) })
      }
      else {
        // Failure leg for 4
        return .Failure(NSError(localizedDescription: "Expected string list. Got: \(array[1])"))
      }
    }
    else {
      // Failure leg for 2
      return .Failure(NSError(localizedDescription: "Expected array. Got: \(json)"))
    }
  }
  else if let error = error {
    // Failure leg for 1
    return .Failure(error)
  }
  else {
    fatalError("Received neither JSON nor an error")
    return .Failure(NSError())
  }
}
```

That's a lot of code, and frankly, it's hard to tell what's going on in there,
even with the comments. Some of it is because of how `if let` works, so the
errors wind up being in distant `else` clauses. But even if you rearranged it, I
think most approaches would look something like this. Lots of if's and returns
to deal with all the possible error conditions. (Or maybe you just skip the
error legs because they're too hard, but then you pay for it later when you're
trying to debug crazy problems in the field. You know I'm talking to you. Don't
deny it.)

I'm going to skip way ahead now and show you where we're going. You're not meant
to understand this code quite yet, but I just want you to compare readability.
This function does *exactly* the same thing as the above function. It has the
same error checks, same success and failure results, passes the same unit tests,
returns the same `NSError` values. Even with no idea what `>==` means, even if
you just call it "the thing you put at the beginning of each step," I'd say this
function is a lot easier to understand and maintain.

```
func pagesFromData(data: NSData) -> Result<[Page]> {
  return data
    >== asJSON
    >== asJSONArray
    >== atIndex(1)
    >== asStringList
    >== asPages
}
```

This isn't about fancy operators or clever tricks. We're not going to discuss
category theory, monads, functors, or combinators (at least not for a
while). We're just going to follow a sequence of "as a real-world developer who
needs to get code out the door, I wish there were a function that..." and see
where it takes us. This is about making code easier to read, understand, write,
and debug. And there are several stops along the way where you can jump off and
still have better code for your trouble.

So, what's the first thing we wish for? Well, a lot of our confusing code is
tied up in different ways of managing success versus failure. It would be nice
if each step dealt with success or failure in the same way. For example, I wish
there were a function that took an `NSData` and returned parsed JSON or an
error. Then it'd look just like the `pagesFromData` function. How about:

```
enum JSONResult {
  case Success(JSON)
  case Failure(NSError)
}
func asJSON(data: NSData) -> JSONResult
```

That's OK, but now we have this `PageListResult` and `JSONResult` that are
almost identical, and obviously that's going to keep repeating. This feels like
a generic problem that we should solve in a generic way:

```
enum Result<A> {
  case Success(A)
  case Failure(NSError)
}
```

And that would be great, except that Beta6 can't quite handle it (known bug,
will hopefully be fixed soon). So in the meantime, to get this we need a `Box`
for our `Success` case:

```
enum Result<A> {
  case Success(Box<A>)
  case Failure(NSError)
}

final class Box<T> {
  let unbox: T
  init(_ value: T) { self.unbox = value }
}
```

So back to our wished-for function, using our awesome new `Result`:

```
func asJSON(data: NSData) -> Result<JSON> {
  var error: NSError?
  let json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(0), error: &error)

  switch (json, error) {
  case (_, .Some(let error)): return .Failure(error)
  case (.Some(let json), _):  return .Success(Box(json))
  default:
    fatalError("Received neither JSON nor an error")
    return .Failure(NSError())
  }
}
```

(If the `.Some` cases are unfamiliar to you, read 
[Unwrapping Multiple Optionals](http://natashatherobot.com/swift-unwrap-multiple-optionals/)
from Natasha the Robot.)

Let's see what happens if we do that for all our functions (you can find all the
helper functions in 
[this gist](https://gist.github.com/rnapier/2c2bccc40b24fb9d54fc)):

```
func pagesFromData(data: NSData) -> Result<[Page]> {

  // 1. Parse the NSData into a JSON object
  switch asJSON(data) {
  case .Success(let boxJson):

    // 2. Make sure the JSON object is an array
    switch asJSONArray(boxJson.unbox) {
    case .Success(let boxArray):

      // 3. Get the second element
      switch secondElement(boxArray.unbox) {
      case .Success(let elementBox):

        // 4. Make sure the second element is a list of strings
        switch asStringList(elementBox.unbox) {
        case .Success(let titlesBox):

          // 5. Convert those strings into pages
          return asPages(titlesBox.unbox)

        case .Failure(let error):
          return .Failure(error)
        }
      case .Failure(let error):
        return .Failure(error)
      }
    case .Failure(let error):
      return .Failure(error)
    }
  case .Failure(let error):
    return .Failure(error)
  }
}
```

We haven't saved any code here. This function, plus the helper functions, is
actually a bit longer than the original. But short code wasn't the goal. Don't
focus on typing. Focus on consistency and clarity. Conciseness will often follow
on its own.

Our function is now incredibly consistent. At each step down the tree we call 
a function that takes `something` and returns a `Result<something-else>`. And
if any of those results are `.Failure`, we return the error. I wish...

Hmmm.... what do I wish? There's clearly a pattern here, and where there are
patterns there are opportunities for functions. Let's think harder about this
pattern.

```
  switch asJSON(data) {
  case .Success(let boxJson):
    switch asJSONArray(boxJson.unbox) {
    case .Success(let boxArray):
      switch secondElement(boxArray.unbox) {
    ...
              return asPages(titlesBox.unbox)
    ...
    case .Failure(let error):
      return .Failure(error)
    }
  case .Failure(let error):
    return .Failure(error)
  }
```

Let's write it a bit more generally:

```
  switch f1(x0) {                // Pass x0 to some function
  case .Success(let x1box):      // If successful,  
    switch f2(x1box.unbox) {        // continue to another function   
    case .Success(let x2box):    // If successful,
      switch f3(x2box.unbox) {      // continue to another function
    ...
              return fn(xn.unbox)     // Return the result of the last function
    ...
    case .Failure(let error):   // If anyone fails, return failure
      return .Failure(error)
    }
  case .Failure(let error):
    return .Failure(error)
  }
```

So I wish I had a function that took "the `Result` so far" and "the next step"
and returned a `Result`. If passed a `.Success`, then it should pass the
contents to the next step. If passed a `.Failure`, then it should stop and
return that. Let's call it `continueWith` for the time being.

    func continueWith<A,B>(a: Result<A>, f: A -> Result<B>) -> Result<B>

Stop. I know you just skimmed over that signature. Go read it again. Make sure
you know what it says. Say it out loud. It takes a result, and a function that
takes something and returns a result, and returns a result. That probably still
didn't make any sense. Go back and think about it until it does. This function
is important. Think about where it says `A` and where it says `B`. It should
start to click in your head pretty quickly once you stop and think about it for
a second and stop speed-reading.

...

Really, don't go on until it makes 90% sense to you. You might be thinking
something like "hey, this kind of converts A into B, but inside a Result." Yeah,
that kind of makes sense. Kind of like `map`, but kind of different. Hold onto
that thought, or whatever thought made it make sense to you (we're all
different). Maybe what you're thinking will be useful later.

...

OK, now that we're on the same page, if we had a function like that, we could
write:

```
func pagesFromData(data: NSData) -> Result<[Page]> {
  return continueWith(asJSON(data)) {     // data is NSData
    continueWith(asJSONArray($0)) {       // $0 is JSON (AnyObject)
      continueWith(secondElement($0)) {   // $0 is JSONArray ([AnyObject])
        continueWith(asStringList($0)) {  // $0 is JSON (AnyObject)
          asPages($0)                     // $0 is [String]
        } } } }                           // We return Result<[Page]>
}
```

That's starting to look kind of nice. I like this `continueWith` function. I
wonder how we'd write it. Well, if it's passed a `.Success`, it unboxes it and
calls the next function.[^unbox] If it's passed a `.Failure`, it returns a
`.Failure`. That doesn't seem too hard:

[^unbox]: Remember that the "unbox" step is just because of a Beta6 compiler limitation.

```
func continueWith<A,B>(a: Result<A>, f: A -> Result<B>) -> Result<B> {
  switch a {
  case .Success(let boxA): return f(boxA.unbox)
  case .Failure(let err):  return .Failure(err)
  }
}
```

That was actually pretty simple. Don't get too used to the name `continueWith`.
We'll be discussing other names for this function later. It's more powerful than
it looks.

You can look at the [full gist](https://gist.github.com/rnapier/0f5611d0bf89a9645713) if you like.

Go back and ponder that last version of `pagesFromData` for a moment. What do
you like about it? What still bothers you?

---

I told you there were several jumping off points in this discussion, and we've
reached one of them. The nested version of this function using `continueWith` is
already a lot easier to reason about than the original version. The techniques
are pretty vanilla for Swift: an enum with associated data, and a function that
takes function. All you need to do is structure your code so each failable step
takes a value and returns a `Result`. You can continue this pattern
indefinitely, keeping the code easy to understand, while still getting good
error messages.

So let's leave it there for this post. Soon we'll push this further, make it
easier to read and more generic. We might even talk more about this interesting
`continueWith` function.

In the meantime, you may be interested in some other explorations of these
topics. They all have spoilers of where we're going, but there's no harm in
that. We each learn in our own way, so maybe one of these approaches will click
best with you.

* Alexandros Salazar's 
[Error Handling in Swift](http://nomothetis.svbtle.com/error-handling-in-swift). 
A must-read series in my opinion. My use of the `Result` type is based directly
on his.
* Tony DiPasquale's
[Efficient JSON in Swift with Functional Concepts and Generics](http://robots.thoughtbot.com/efficient-json-in-swift-with-functional-concepts-and-generics), which is a
direct influence on this work, but may be a bit fast-paced for many readers.
* Chris Eidhof's
[Parsing JSON in Swift](http://chris.eidhof.nl/posts/json-parsing-in-swift.html)
which is quite nice if you already understand where this is going, but jumps
into the deep end very quickly.

If Tony or Chris's posts make perfect sense to you, maybe you don't need my
series. If you leave them a little befuddled, then this series will get to the
same place, just a bit more gently.

Until then, stop mutating. Evolve.