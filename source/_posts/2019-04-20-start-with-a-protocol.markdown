---
layout: post
title: 'Protocols I: Start with a protocol'
date: 2019-04-22
---

## In the beginning, Crusty

In 2015, at WWDC, [Dave Abrahams](https://twitter.com/DaveAbrahams) gave what I believe is still the greatest Swift talk ever given, and certainly the most influential. [”Protocol-Oriented Programming in Swift,”](https://developer.apple.com/videos/play/wwdc2015/408/) or as it is more affectionately known, “The Crusty Talk.” 

This is the talk that introduced the phrase “protocol oriented programming.” The first time I watched it, I took away just one key phrase:

> Start with a protocol.

And so, dutifully, I started with a protocol. I made a UserProtocol and a DocumentProtocol and a ShapeProtocol and on and on, and then started implementing all those protocols with generic subclasses and eventually I found myself in a corner.

```
Protocol 'P' can only be used as a generic constraint because it has Self or associated type requirements
```

And then I started throwing things.
<!--more-->

For several years, I was rather annoyed at the phrase "protocol-oriented programming." If by "protocol" you just mean "interface," then Go is much more "protocol oriented" than Swift. But the more I've wrestled with this new paradigm, the more I realized that POP isn't really about the protocols. It's about the extensions. But "extension-oriented programming" would be an even worse name. And more than just extensions, it's really, deeply, about generic algorithms. And "algorithm-oriented programming," well, aren't we all?

Naming a paradigm is always fraught with trouble. Most modern "object-oriented" languages aren't object-oriented at all. They're class-oriented (vs Smalltalk and JavaScript). And most "functional programming" languages are mostly value-oriented (vs FP and point-free). But the point of the names is shorthand for concepts bigger than a word, so let's not get too caught up on the "protocol" in protocol-oriented programming. The Holy Roman Empire was in no way holy, nor Roman, nor an empire. Discuss.

## Beware quotes traveling sans context

The famous "start with a protocol" quote is actually the end of a longer paragraph:

> For example, if you want to write a generalized sort or binary search…Don't start with a class. Start with a protocol.

Or as Dave [clarified on Twitter](https://twitter.com/cocoaphony/status/1104114233288151043):

> Use value types, then if you need polymorphism, make them conform to protocols.  Avoid classes.

*If* you're reaching for class inheritance, try a protocol and value type instead. That's very different from "start with a protocol for every problem." [Ben Cohen](https://twitter.com/AirspeedSwift) covered this in much more detail in the WWDC 2018 talk [Swift Generics (Expanded)](https://developer.apple.com/videos/play/wwdc2018/406/). 

> So notice that we considered a varied number of concrete types first. And now, we're thinking about a kind of protocol that could join them all together. And, it's important to think of things as this way around. To start with some concrete types, and then try and unify them with a protocol.

{% pullquote %}
If you take away one thing from this series, I want it to be this: *{" Write concrete code first. Then work out the generics. "}* Start with concrete types and clear use cases, and find the places that duplication happens. Then find abstractions to fix those problems. The power of protocol-oriented programming is that you don’t have to decide when you make a type exactly how that type will be used. When you work with inheritance, you have to design your class hierarchy from the start. But with protocols, you can wait until later.
{% endpullquote %}

When I most get into trouble with protocols is when I try to write code "as generically as possible." That doesn't really mean anything. Abstractions are choices, and when you make a choice to be flexible in one direction, you generally make it harder to be flexible in other directions. Without some clear use cases, you don't know what abstractions make sense.

So today, I want to come to protocol-oriented programming fresh, with a focus on very every-day problems we face when developing iOS apps in Swift.

## Setting the stage

In the next several articles, I'll be developing a very common system, a general-purpose networking stack that can fetch data asynchronously and decode arbitrary types. You may have built a system like this yourself in Swift. You may have used a framework that does it. The point of this exercise isn't really the end result (though I think it's quite useful code), but the process. What questions should you ask, and when, and how do you know what good answers look like? And most importantly, how does this "protocol oriented programming" thing guide us? How is it different than other approaches?

So to get started, I want to show a common starting point that never goes well for me. I've tried to build it this way several times myself, and I always find myself in a corner eventually. I see a lot of other people make this same mistake.

```
// This will not go well.
// Trying to model a Request as something that can fetch and parse a Response.
protocol Request {
    associatedtype Response
    func parse(data: Data) throws -> Response
    var urlRequest: URLRequest { get }
}
```

How do I know this won't go well? I'll discuss it much more in depth later, but Request is a protocol with associated type (PAT). Any time you create a PAT, you should ask yourself "will I ever want to put this in an Array?" If the answer is yes, you don't want a PAT. Requests are certainly something you'd want to put in an Array. Lists of pending requests, lists of requests that need to be retried, request priority queues. There are lots of reasons to put a Request in an Array.

You might be tempted to look for a work-around, but don't. Type-eraser? No. Generalized Existential?!?! ...no... Even if you find some "work-around" to the problem at hand you'll run into other walls very quickly (and I've seen that again and again). That `can only be used as a generic constraint` is actually telling you something important. This isn't a problem with Swift. This just isn't what PATs are for. We'll get to what they're for soon, but the basic problem here is starting with a protocol before we even know what algorithm we want to write.

So what does "know the algorithm" look like in practice? Glad you asked. Stay tuned for part two.