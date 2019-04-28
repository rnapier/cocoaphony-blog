---
layout: post
title: 'Protocols Sidebar I: Protocols are nonconformists'
date: 2019-04-28 12:43 -0400
---
[Last time]({% link _posts/2019-04-20-start-with-a-protocol.markdown %}), I mentioned something in passing:

> I need a protocol that requires that the type be Decodable, and also requires that it provide this extra string, `apiBase`.

Read that again. It *requires* that the type be Decodable and also *requires* other things. I didn’t say that Fetchable *is* Decodable. It isn’t.
<!--more-->

## Protocols do not conform

Protocols (with a few exceptions) do not conform to protocols, not even to themselves. A type that conforms to Fetchable, must also conform to Decodable, but Fetchable is not Decodable. Fetchable is not Fetchable. Decodable is not Decodable. Why do I keep repeating this. Because you will forget, and it will bite you. What would it mean if Decodable were Decodable?

```swift
func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
```

Well, remember that JSONDecoder’s `decode` method requires a type that conforms to Decodable. If Decodable (or Fetchable) conformed to Decodable, I could write:

```swift
let result = try JSONDecoder().decode(Decodable.self, from: data)
```

And in fact, I see people try to write that all the time. But how could that possibly work? How can JSONDecoder know which of an unbounded number of possible types you want this JSON to be decoded into? Even if you did it, what could you possibly do with `result`? It's only known method would be `decode`.

And so again: Protocols do not conform to protocols, not even to themselves.

## There's <strike>always</strike> usually an exception

OK, what about the exceptions? There *are* a some protocols that do conform to themselves. `@objc` protocols do unless they have "static" requirements such as `init`, or static properties or methods. And in Swift 5, Error conforms to itself so that you can say `Result<T, Error>`. If Error didn't conform to itself, you'd have to use a concrete type for the error. But these are compiler-enforced special cases. You can't make *your* protocol conform to itself.

## Impossible? Or just not implemented?

But could they? Yes, some could in principle. The rule is pretty straightforward: if a protocol includes an `init` or `static` requirement, or includes a `Self` method parameter, then self-conformance is tricky. If there is no such requirement, then it it's much more straightforward (basically the same as for `@objc`). There's no deep reason that Encodable can't be Encodable. The following could work, and I think would be both sensible and useful, it just doesn't today:

```swift
let encodables: [Encodable] = ...
try JSONEncoder().encode(encodables)
```

Will this ever work? I don't know. It's been brought up a few times on [Swift Evolution](https://forums.swift.org/t/will-existentials-ever-conform-to-their-protocols/4919), and hasn't been rejected outright. One concern is that adding an `init` requirement to an existing protocol could break existing usage (possibly in downstream code) in ways that might surprise developers. I haven't found a clear statement, but it seems the team wants to make this work someday.

It's even possible that "challenging" protocols could self-conform if there were default implementations. One could imagine a Swift where `Collection(1, 2, 3)` would return an Array in a Collection existential. (I'm not suggesting that would be a good idea; I really don't know. It's just that it's the kind of thing one could imagine.)

In this series I'm generally going to talk about things I know from experience using today's Swift or can predict about likely-near-term Swift (i.e. there's an SE in the works). So any time I say something like "that won't work," I mean "without adding a significant feature to Swift that I don't know is planned." (Hopefully folks will continue to correct me if I'm misleading about how hard something would be.)

## I of course mean "existentials"

I want to talk about this more later, but when I say "a protocol doesn't conform to itself," it's more accurate to say "the existential of a protocol doesn't conform to that protocol." But again, that's for a later sidebar....

So that's just a quick side-bar. Next time, I'll continue expanding the network stack.