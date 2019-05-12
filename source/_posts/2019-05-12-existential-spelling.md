---
layout: post
title: "Protocols III: Existential Spelling"
---

*This was supposed to be a quick sidebar, but it turned into a full-length article, so I'm calling it part 3. The original part 3, continuing the network stack, is mostly done, but I wanted to explain this weird word "existentials" first, and it turned out longer than I'd expected. Blame Joe Groff; he's written too much interesting stuff lately and I want to talk about it.*

If you're interested in the future of generics in Swift, Joe Groff has a must-read post called [Improving the UI of generics](https://forums.swift.org/t/improving-the-ui-of-generics/22814). (You should also read the linked [Generics Manifesto](https://github.com/apple/swift/blob/master/docs/GenericsManifesto.md) for background.) In it, he touches on a common confusion in Swift. If you don't understand what he's talking about here, don't worry. Explaining this paragraph is the point of this article.

> We gave existential types an extremely lightweight spelling, just the bare protocol name, partially following the example of other languages like Java and C# where interfaces also serve as value-abstracted types, and partially out of a hope that they would "just work" the way people expect; if you want a type that can hold any type conforming to a protocol, just use the protocol as a type, and you don't have to know what "existential" means or anything like that. In practice, for a number of reasons, this hasn't worked out as smoothly as we had originally hoped. Although the syntax strongly suggests that the protocol as a constraint and the protocol as a type are one thing, in practice, they're related but different things, and this manifests most confusingly in the "Protocol (the type) does not to conform to Protocol (the constraint)" error.
<!-- more -->

## Spelling?

In programming languages, the "spelling" of something is the sequence of characters a programmer would type to represent a concept. This is often the most visible and argued-over part of a language. It's also often a fairly shallow concern to the design, which is why it's common to use intentionally bad "straw man" names to discuss a concept without getting bogged down in spelling. Consider the concept "true if `x`  or `y`, otherwise false." Swift spells that  `x || y`. In [SML](https://en.wikipedia.org/wiki/Standard_ML) the same concept is spelled `x orelse y`. But the spelling difference, the difference between the characters `||` and `orelse`, isn't very important. It doesn't tell you much about how the language works. A more interesting difference, at least to me, is that `||` is a [stdlib function in Swift](https://github.com/apple/swift/blob/c2ecf6d9fb030e767f43bb85fc6ac862ec6fe493/stdlib/public/core/Bool.swift#L320-L323), while `orelse` is hard-coded into the SML compiler, which would likely be true no matter how they were spelled.

In English, some spellings have multiple meanings. The same thing happens in programming languages, and it happened in the [last article]({% link _posts/2019-04-29-a-mockery-of-protocols.md %}):

<style>
    .chl { color: yellow; } /* code highlight */
</style>

<pre>
final class AddHeaders: <span class="chl">Transport</span>
{
    let base: <span class="chl">Transport</span>
    ...
}
</pre>

The spelling "Transport" has two related, but distinct, meanings. The first refers to the *protocol* Transport. The second refers to the *existential of* Transport.

## Existential?

The "existential of a protocol" can mean several things, but here it refers to a compiler-generated box that holds a value that conforms to the protocol. To see why Swift needs this box, consider an Array of Transports:

```swift
// URLSession and TestTransport both conform to Transport
var transports: [Transport] = [URLSession.shared, TestTransport(...)]
```

Swift would like to store Arrays contiguously in memory. So for an Array of Ints, the storage looks like this:

```
+---+---+---+
| 0 | 1 | 2 |
+---+---+---+
```

There are no pointers or indirection. The Ints are stored one after the other. To find the offset of index 2, you just have to multiply the size of an Int times two. That's really fast and how you probably expect Arrays to work. Swift does the same thing for structs. It just lays them out field after field (there might be some padding, but that's not important here).

```
struct S {
    let a: Int
    let b: Int
}

++--------+--------++--------+--------++--------+--------++
|| S[0].a | S[0].b || S[1].a | S[1].b || S[2].a | S[2].b ||
++--------+--------++--------+--------++--------+--------++
```

Again, to find the offset of `S[2]`, Swift just has to multiply two times the size of S (which is the same as two Ints). But what happens in a "protocol-typed" Array like `[Transport]`? Each element might be a different size. What can Swift do?

It makes a box that's a fixed size (currently three machine words). If the type can fit in the box, then it's stored in the box. If it can't fit, then the compiler allocates some  space, copies the data there, and puts a pointer in the box. Reference types are already pointers, so it just puts the pointer in the box. In Swift, that box is called an *existential container*. The thing in the box is called a *witness*.

*See [WWDC 2016: Understanding Swift Performance](https://developer.apple.com/videos/play/wwdc2016/416/) for more on the implementation details.*

## Sure, but "existential?"

*This section is a bit more technical; feel free to skip it if you like.*

Why "existential?" Because the Transport protocol asserts that there *exists* some type that satisfies its requirements. By "some type," I mean "in the universe of all possible types," not "types that happen to be in your program." That assertion may be wrong. It's possible to define a protocol that nothing could ever conform to. For example:

```swift
protocol Impossible {
    func make<A>() -> A 
}
```

(If you don't believe me, spend some time trying to implement `make`. You need to return an instance of *whatever* the caller requests.)

An existential container is a placeholder box for some unknown type that satisfies the protocol. It's possible there is no such type, or there may not be any such type in your program. Nothing can be done with it at runtime until a real, concrete value, a *witness*, is put in the box. The existence of a witness proves that such a type really does exist.

This implicit box isn't the only example of an existential in Swift. The "Any" types like AnySequence, AnyHashable, and AnyKeyPath often get called "type-erasers" because they hide the concrete type, but they're also explicit existentials. [In future Swift,](https://forums.swift.org/t/improving-the-ui-of-generics/22814#heading--clarifying-existentials) we may spell implicit existentials as `any Transport` to parallel the explicit spelling.

While protocols create existential ("there exists") types, generics create universal ("for all") types. When you write `struct Array<Element> {...}`, that's an assertion that "for all types (Element), there is another type (Array&lt;Element&gt;) with the following attributes...."

Existentials and universals are "duals," which means that one can be transformed into the other without losing its structure. So AnySequence is a universal type (generic) that's equivalent to an explicit existential of Sequence (protocol). That's why when you run into problems with protocols, your solution may be to convert it into generic structs (or vice versa). They solve the same problems in different ways with different trade-offs.

## Copy values or code?

If you have a function with a parameter whose type is a protocol, that really means it requires an existential of that protocol.

```swift
protocol Transport { ... }
func transmit(data: Data, over transport: Transport) { ... }
```

In order to call `transmit` with URLSession, Swift needs to copy the URLSession into an existential, and then pass that to `transmit`.

What if you used a generic function instead?

```swift
func transmit<T: Transport>(data: data, over transport: T) { ... }
```

This says that the caller gets to decide the type of T. If they pass URLSession, then the compiler creates an implicit overload:

<pre>
func transmit(data: Data, over transport: <span class="chl">URLSession</span>) { ... }
</pre>

If somewhere else in the code they pass TestTransport, then the compiler creates another overload:

<pre>
func transmit(data: Data, over transport: <span class="chl">TestTransport</span>) { ... }
</pre>

The entire `transmit` function is (in principle) copied, just as if you'd written an overload `transmit` for each type. This is an over-simplification, and the compiler may not actually make all the copies, or it may generate an existential version instead (or in addition). It depends on a lot of things, including the optimization flags. But when you call a generic function, you should think of it as creating a new version of the function written specifically for the type you called it with.[^performance]

[^performance]: All these "may" qualifiers are why you shouldn't assume that protocols or generics are "better for performance" (for whatever meaning you're attaching to "performance"). It depends on a lot of things. If your code is sensitive to the performance of generics or protocols, you need to profile it and look at what the compiler is actually generating. Do not take away from this discussion that "generics are faster" or "protocols create smaller binaries." That might be true in certain cases, but it can also be the other way around. Write you code clearly and correctly, and say what you mean in types. The Swift compiler teams works very hard to make sure that kind of code will be performant. Don't guess what the compiler will do. Test.

* In an existential (protocol parameter) function, the parameters may need to be copied into an existential at *run-time*.
* In a generic function, duplicate copies of the code may be generated at *compile-time*.

This run-time/compile-time distinction is a key difference between existentials and generics. Existentials are containers that are filled at run-time. Generics are compile-time functions for generating new code.

Existentials are used when you need to store heterogeneous values that are only known at run-time, for example in a heterogeneous collection.

Generics are used to apply algorithms to types that are known at compile-time. Protocols constrain what types can be used with those generics.

You don't pass "a protocol value" to a function. You pass the existential of the protocol. Because Swift often converts concrete types into existentials for you, it's easy to forget that they're not the same thing. So when Swift doesn't perform the conversion, it comes as a surprise, and we get the "can only be used as a generic constraint" (i.e. "as a protocol") error.

## What if we made things more generally...um...existential?

So couldn't Swift just create an existential all the time, even for protocols with associated types (PATs)? Yes, but...it's complicated. For the most common cases, yes, Swift could automatically create an `any Collection<.Element == T>`[^protocol-syntax] implicit existential just like it currently has an `AnyCollection<T>` explicit existential. That idea is called *generalized existentials*, and I'm pretty certain Swift will add it eventually (maybe even soon). That'll knock off several of protocols' sharp edges for some of the most common cases.

[^protocol-syntax]: For an introduction to that proposed syntax, see the [Protocol<.AssocType == T> shorthand](https://forums.swift.org/t/protocol-assoctype-t-shorthand-for-combined-protocol-and-associated-type-constraints-without-naming-the-constrained-type/21217) forum thread.

{% pullquote %}
But it probably won't solve as many problems as people expect. {" Many protocol problems I see in the wild are really just design problems that have little to do with missing Swift features. "} A generalized existential will get you past the compiler error, but in the process it may let you go much further down a wrong road.
{% endpullquote %}

And there are many kinds of types that don't lend themselves to automatically-generated existentials. The compiler can't fulfill an `init` requirement or any `static` requirements on its own. It needs help from the programmer to determine what the default implementations are. It's similar for protocols with a Self requirement. It may not always be possible to create a sensible default implementation. For protocols like Decodable that have no instance methods, an existential may not make sense at all.

## Why you gotta talk about math so much?

As Joe said, the hope was that existentials wouldn't really matter. They're created by the compiler, you can't access them, and you can't even refer to them directly in the language today. You'd think they'd be an implementation detail. But sometimes when you type the name of a protocol you mean the protocol and sometimes you mean the box, and sometimes that matters. We'd like to ignore reference counting, too, and mostly we can...except when we can't.

The point of a protocol is algorithms. Protocols express what a type must be able to do in order to be used in certain ways. Ideally, protocols should have a very small number of requirements, and enable a large number of extensions and generic functions. A good protocol is short, but shows up in a lot of `where` clauses and extensions. They're fundamentally about compile-time type concerns. "I want to apply this algorithm to many different concrete types."

The point of an existential is heterogeneous collections, or "type-erasure" where you want to know less about the specific type and just use it according to an interface. They're fundamentally about run-time values. "I want to assign values of many different concrete types to this variable."

They're not unrelated, but they're not the same thing. When I say ["protocols do not (generally) conform to protocols,"]({% link _posts/2019-04-28-nonconformist.markdown %}) I *really* mean "existentials do not (generally) conform to protocols." And when you see "can only be used as a generic constraint," what the compiler is really telling you is that protocols with associated types (PATs) don't have an existential. 

## So what about these opaque result things?

My hope is that after reading all this, you'll feel more comfortable reading [SE-244](https://github.com/apple/swift-evolution/blob/master/proposals/0244-opaque-result-types.md), which adds opaque return types in Swift 5.1. I don't expect opaque return types to be an important feature for most developers. Please don't assume you need to rewrite your code to use them. The problems they solve impact stdlib much more than day-to-day app development in my opinion. Looking over my code, I haven't found a single place I want to use one.

The importance of SE-244 isn't opaque return types. It's that it lays the groundwork for the future of Swift generic code. If that interests you, then you definitely want to study it, and in particular get comfortable with `any P` (an existential) versus `some P` (an unknown but concrete type that conforms). Hopefully this article demystifies some of the terminology.

Next time, back to the networking stack and hopefully some more practical concerns.

---
