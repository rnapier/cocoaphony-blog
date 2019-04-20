---
layout: post
title: "Do you know Swift now?"
comments: true
published: false
categories: 
---

More than a year of Swift. A new major version. Code debugged. Blogs pontificated. It's a fair time to ask, [do you know Swift now?](i-dont-know-swift).

Of course not. You knew the answer. ["Any headline that ends in a question mark can be answered by the word *no*."](https://en.wikipedia.org/wiki/Betteridge%27s_law_of_headlines) But I know some things I didn't know last July. And you hopefully know some things you didn't know last July. So let's swap notes a bit. Since this is my blog, I'll go first. You can write your own blog.

It's worth remembering that Swift is still insanely new and we will see a lot of changes to come, changes that dramatically change what patterns make sense. [NeXT-era ObjC](http://www.nextcomputers.org/NeXTfiles/Docs/Developer/Intro_to_Objective_C_on_the_NeXT_Machine.pdf) is significantly different from modern ObjC. But we've seen anough iterations now to start to get a sense of where things are headed, which parts are intentional and which are temporary. I'm getting to see which of my predictions have held up, and which were way off base.

I think my most important (and earliest) prediction has held up very well: [Swift is not functional](http://robnapier.net/swift-is-not-functional). If you still doubt me, go watch [Building Better Apps with Value Types in Swift](https://developer.apple.com/videos/wwdc/2015/?id=414) from WWDC 2015. In my opinion that's the most important talk at WWDC after [Protocol-Oriented Programming in Swift](https://developer.apple.com/videos/wwdc/2015/?id=408). POP ("the Crusty talk") drove home my early misunderstanding of Swift. I said it was "OOP/generic" and that wasn't right. Apple says it's "protocol-oriented," and that's definitely the direction they've been headed. I object to the claim that Swift is "the first protocol-oriented programming language," since I would classify Go in that paradigm.[^go] But there is every indication that the team intends to make protocols central to Swift programming over time.

[^go]: Go interfaces are much more central to Go than Swift protocols are to Swift. Go interfaces are its only form of user-definable polymorphism. Swift protocols are just one option. [Go interfaces were central from the beginning.](http://commandcenter.blogspot.com/2012/06/less-is-exponentially-more.html) Swift protocols still need some work to reach their intended potential. That's mostly because Swift is also generic and Go is not. Generics make everything more <strike>complicated</strike> expressive.

My prediction that you should use `let` rather than `var` as often as you can was correct. It's now even a compiler warning. This did not imply that Swift favors immutability. It is relatively neutral on the matter. Access controls turned out to be pretty close to predictions. Even if `private` surprises some folks, I think file-scope is a great approach and very much in line with Swift's low-inheritance style.

I never saw `throws` coming. <Insert stupid pun here.>

So what do we know that we didn't before? What is best in Swift?

Swift is a duck-typed language.

>When I see a bird that walks like a duck and swims like a duck and quacks like a duck, I call that bird a duck. -- James Whitcomb Riley

This may surprise some folks. We often think of dynamic languages as duck typed. But I think it's the heart of where Swift wants to be. It doesn't matter what something *is*; it matters what it can *do*.

```swift
protocol DuckType {
    typealias Sound: Listenable
    func walk(direction: DirectionType, distance: DistanceType) throws
    func quack() -> Sound
    func swim(direction: DirectionType, distance: DistanceType) throws
}
```

Figuring out the best pattens for this is going to be a big part of writing good Swift code. How large should protocols be? A single method? Most stdlib protocols collect at least a few requirements. It's not completely clear when `...able` is the better name versus `...Type`. Why `SequenceType` rather than `Iterable`? History or intent? Final or still subject to change? Stdlib is still in flux, and we're all still working out the right intuitions.

Swift loves extensions. Loves them. I count 236 extensions in stdlib (compare 87 structs, 82 protocols, and 7 enums). A lot of work was done recently to make extensions much more powerful, particularly by allowing them to apply to protocols. That makes it much easier to handle most functionality through extensions and protocols rather than class inheritance.

Swift has no love of class inheritance. I count 5 classes in stdlib, one of which is `final`, and just one with non-trivial inheritance (`ManagedBuffer`). If you have a deep Swift class hierarchy, I think you're doing it wrong. Protocols and extensions. Protocols and extensions.

But does Swift love only structs and discourage classes? No. The [Swift guide](https://developer.apple.com/library/prerelease/ios/documentation/Swift/Conceptual/Swift_Programming_Language/ClassesAndStructures.html) still says:

> As a general guideline, consider creating a structure when one or more of these conditions apply:

> * The structure’s primary purpose is to encapsulate a few relatively simple data values.
* It is reasonable to expect that the encapsulated values will be copied rather than referenced when you assign or pass around an instance of that structure.
* Any properties stored by the structure are themselves value types, which would also be expected to be copied rather than referenced.
* The structure does not need to inherit properties or behavior from another existing type.
>
> ... 
>
> In all other cases, define a class, and create instances of that class to be managed and passed by reference. In practice, this means that most custom data constructs should be classes, not structures.

This is the guidance I've most often seen resisted by Swift devs. It's guidance I resisted for months, because structs seem so much more "pure." But it's played out in my code. I've created several difficult-to-diagnose bugs by using structs when I should have used classes. So far, I've never created bugs the other direction. Maybe that's just my comfort and familiarity with ObjC patterns, but it's still the truth. That said, my intuition is that most classes should be marked `final` unless you have a good reason otherwise.

So what don't we know? I think there's a lot, and there are many things still to be discovered within the community.

What's the best patterns for async, especially how it interacts with `throws`? This feels like a must-address issue for Apple. GCD is brilliant as C interface, but Swift can do better.

When does it make sense to use `throws` versus an `Optional` versus `fatalError`? Should everything that can fail be `throws`? Imagine if subscripting an array required `try`? Would that really be best? (I suggested [subscripts return Optional](http://www.openradar.me/17937594) a year ago. I was probably wrong. I'm wrong a lot. Think for yourselves.)

How should we name public things in modules? It's fine that the compiler protects us from explicit collisions, but if you have public symbols like `Message`, isn't that still confusing to consumers of your module who may have several "message-like" things? But prefixing your symbols (`MyGreatModuleMessage`) seems to go against the whole point of modules. Swift has no "public but not exported" today. What should we do?