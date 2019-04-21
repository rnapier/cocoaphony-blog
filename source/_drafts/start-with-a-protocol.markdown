---
layout: post
title: Start with a protocol
date: 2019-04-20
---

## In the beginning, Crusty

In 2015, at WWDC, [Dave Abrahams](https://twitter.com/DaveAbrahams) gave what I believe is still the greatest Swift talk ever given, and certainly the most influential. [”Protocol-Oriented Programming in Swift,”](https://developer.apple.com/videos/play/wwdc2015/408/) or as it is more affectionately known, “The Crusty Talk.”

This is the talk that introduced the phrase “protocol oriented programming.” The first time I watched it, I took away one key lesson:

> “Start with a protocol.”

And so, dutifully, I started with a protocol. I made a UserProtocol and a DocumentProtocol and a ShapeProtocol and on and on, and then started implementing all those protocols with generic subclasses and eventually I found myself in a corner.

```
Protocol 'P' can only be used as a generic constraint because it has Self or associated type requirements
```

And then I started throwing things.

For several years, I was rather annoyed at the phrase "protocol-oriented programming." If by "protocol" you mean "interface" then Go is much more "protocol oriented" than Swift. But the more I've wrestled with this new paradigm, the more I realize It's not about the protocols. It's about the extensions. But "extension-oriented programming" would be an even worse name. And more than just extensions, it's really, deeply, about generic algorithms. And "algorithm-oriented programming," well, aren't we all?

Naming a paradigm is always fraught with trouble. Most modern "object-oriented" languages aren't object-oriented at all. They're class-oriented (vs Smalltalk and JavaScript). And most "functional programming" languages are more "value-oriented" (vs FP and point-free). But the point of the names is shorthand for concepts, so let's not get too caught up in the word "protocol" in protocol-oriented programming. The Holy Roman Empire was in no way holy, nor Roman, nor an empire. Discuss.

## Beware quotes traveling sans context

The famous "start with a protocol" quote is the end of a longer paragraph:

> “For example, if you want to write a generalized sort or binary search…Don't start with a class. Start with a protocol.”

Or as Dave [clarified on Twitter](https://twitter.com/cocoaphony/status/1104114233288151043):

> "use value types, then if you need polymorphism, make them conform to protocols.  Avoid classes."

*IF* you're reaching for class inheritance, try a protocol and value type instead. That's a very different recommendation from "start with a protocol for every problem." [Ben Cohen](https://twitter.com/AirspeedSwift) covered this in much more detail in the WWDC 2018 talk [Swift Generics (Expanded)](https://developer.apple.com/videos/play/wwdc2018/406/). 

> So notice that we considered a varied number of concrete types first. And now, we're thinking about a kind of protocol that could join them all together. And, it's important to think of things as this way around. To start with some concrete types, and then try and unify them with a protocol.

{% pullquote %}
If you take away one thing from this series, I want it to be this: {" Write concrete code first. Then work out the generics. "} Start with concrete types, and clear use cases, and find the places that duplication really happens. Then find abstractions to fix those problems. The power of protocol-oriented programming is that you don’t have to decide when you make a type exactly how that type will be used. When you work with inheritance, you have to design your class hierarchy from the start. But with protocols, you can wait until later.
{% endpullquote %}

When I most get into trouble with protocols is when I try to write code "as generically as possible" without having a clear use case in mind. That doesn't really mean anything. Abstractions are choices, and when you make a choice to be flexible in one direction, you generally make it harder to be flexible in other directions.

So today, I want to come to the concepts of protocol-oriented programming fresh, with a focus on very every-day problems we face when developing iOS apps in Swift.

## Revisiting Crusty

About half the Crusty talk revolves around one long example, a “diagramming app where you can drag and drop shapes on a drawing surface and interact with them.” It’s a very classic object-oriented problem, and in an OOP language I'd probably focus on laying out the model classes first. Maybe something like this:

```
class Shape {
    var center: CGPoint
    init(center: CGPoint) {
        self.center = center
    }
}

class Circle: Shape {
    var radius: CGPoint
    init(center: CGPoint, radius: CGPoint) {
        self.radius = radius
        super.init(center: center)
    }
}
```

That feels ok at first glance, but it actually has some pretty major problems already. Yes, there's the reference/value type arguments about unintentional sharing and mutable state, but that's not really my focus here. We could make these types immutable and make those problems go away (creating other problems, but still....) The real problem in my opinion is the `center` property. What happens when I try to implement Polygon?

```
class Polygon: Shape {
    var corners: [CGPoint]
    init(corners: [CGPoint]) {
        self.corners = corners
        super.init(center: ???) // What is the center?
    }
}
```

Is the center the [centroid](https://en.wikipedia.org/wiki/Centroid)?