## You're not alone. Swift protocols confuse us all.

This is going to be a fairly long series, in words if not in number of posts. I tend to ramble a bit about philosophy, and there will be quite a lot of code. Usually I'd let the important points reveal themselves along the path. But Swift protocols are too important to let the most critical points be buried in mountains of text, so I'm going to
reveal all the important points here before I get started. If I forget something, I may come back and update this section. Also, if the statements in this list are either obvious to you, or not interesting, this series probably isn't for you.

* Write concrete code first. Then work out the generics.
* Do not create "genericness" for its own sake. Discover it in your concrete use case.
* Abstractions are choices. They cut you off from other abstractions. "As generic as possible" doesn't mean anything.
* The point of a PAT is to apply generic algorithms to a type. It is never to create a heterogeneous collection.
* Simple (non-PAT) protocols are commonly used to create a heterogeneous collection
* Before you add an associated type, ask: "Would it be sensible to put this type in an array?" If the answer is yes, do not add an associated type. Redesign.
* You probably don't need a type-eraser. If you're trying to put a PAT in an array, you *definitely* don't need a type-eraser. Redesign.
* Generalized existentials probably will not solve your problem. Redesign.
* Protocols are not abstract classes. Swift doesn't have abstract classes. If your protocol inheritance would make perfect sense as an abstract class hierarchy, you're probably on the wrong road.
* Protocols (almost) never conform to protocols. When you need "a type that conforms to P," P is not that type.
* A protocol cannot *be* Equatable. It can only *require* Equatable.
* Aspire to more than "mocks" from your protocols.
* Protocols are not bags of syntax. They have have semantics (meanings) and exist to facilitate interesting algorithms.

That's a lot to talk about, and this will be a dense and meandering series. It's time to dive into it. This article will just set the stage. I've been wrestling with protocols since the the first day of Swift. I've used them incorrectly and had to redesign so many times I've lost count. I've crashed the compiler so many times that it's lost count. You are not alone.

---

## Revisiting Crusty

About half the Crusty talk revolves around one long example, a “diagramming app where you can drag and drop shapes on a drawing surface and interact with them.” It’s a very classic object-oriented problem, and in an OOP language I'd probably focus on laying out the model classes first. Maybe something like this:

```
class Shape {
    var center: CGPoint
    init(center: CGPoint) {
        self.center = center
    }
}

class Circle : Shape {
    var radius: CGFloat
    init(center: CGPoint, radius: CGFloat) {
        self.radius = radius
        super.init(center: center)
    }
}
```

That feels ok at first glance, but it actually has some pretty major problems already. Yes, there's the reference/value type arguments about unintentional sharing and mutable state, but that's not really my focus here. We could make these types immutable and make those problems go away (creating other problems, but still....) The real problem in my opinion is the `center` property. What happens when I try to implement Polygon?

```
class Polygon : Shape {
    var corners: [CGPoint]
    init(corners: [CGPoint]) {
        self.corners = corners
        super.init(center: ???) // What is the center?
    }
}
```

Is the center the [centroid](https://en.wikipedia.org/wiki/Centroid), or the center of the bounding box? It's implemented as a property in Shape, so every subclass must maintain it as a property and keep it in sync with any changes to other properties. Is it even used by anything? Do we need to make these decisions yet?

The problem with class inheritance is that it pushes you to make all these choices early, before you've worked out your use cases. The power of protocol-oriented programming is that it lets you make these decisions late. In Swift, I've learned to implement Circle and Polygon this way:

```
struct Circle {
    var center: CGPoint
    var radius: CGFloat
}

struct Polygon {
    var corners: [CGPoint]
}
```

That's it. No protocols. No inheritance. Nothing. It's data, stored in whatever is convenient for that data. But I probably wouldn't create these at all, yet. I don't know what I'm going to do with this data. Instead of starting with models, start with the caller.

My goal is to draw "things" of some kind in a CGContext:

```
for thing in things {
    thing.draw(in: context)
}
```

What should I call these Things? Shapes? Kind of, but that's not really what defines them here. They're just "something that can draw itself into a context." And they need exactly one method, `draw`, so Drawable is a good name.

```
protocol Drawable {
    func draw(in context: CGContext)
}
```

Some of you have seen Crusty's talk and you might be shouting "no, no, not CGContext. You want Renderer." But I don't, at least not yet. That isn't my use case. I just need to draw "drawable things" in a CGContext. Build simply. Then find your protocols. I'm hoping this is going to work out, but to be sure, I should make a few of these Drawables and see if this idea makes sense. 

The simplest thing to draw is a circle, so I'm hoping this is easy to draw:

```
extension Circle : Drawable {
    func draw(in context: CGContext) {
        context.addArc(center: center, radius: radius,
                       startAngle: 0, endAngle: .pi*2,
                       clockwise: true)
    }
}
```

Looks good. That's exactly the kind of to-the-point method I expect in order to implement Drawable.

```
extension Polygon : Drawable {
    func draw(in context: CGContext) {
      context.move(to: corners.last!)
      for p in corners { context.addLine(to: p) }
    }
}
```

And again, looking very good and to-the-point. We should try something a little different, like a container for other Drawables:

```
struct Diagram {
    mutating func add(_ other: Drawable) {
        elements.append(other)
    }

    var elements: [Drawable] = []
}

extension Diagram: Drawable {
    func draw(in context: CGContext) {
        for f in elements { f.draw(in: context) }
    }
}
```

Again, this looks very straight forward. It's important to try to conform several kinds of types early in the process. You want to find where your protocol might run into trouble. If all you implement are the trivial types, then there may be major problems lurking in your design. For example, here's a Drawable that Crusty didn't consider:

```
struct Text {
    var position: CGPoint
    var attributedString: NSAttributedString
}

extension Text: Drawable {
    func draw(in context: CGContext) {
        
        // Configure the context
        context.textMatrix = .identity
        context.textPosition = position

        // Draw the text
        let line = CTLineCreateWithAttributedString(attributedString)
        CTLineDraw(line, context)
    }
}
```

That's actually a bit complicated. It's only four lines, but it already makes me a little nervous. I know I want to swap out CGContext at some point, but this requires Core Text functions that aren't part of CGContext. That tells me it's time to start thinking about abstracting CGContext before this gets out of hand.

---

>> Another case is where the instances of the abstraction are just "sinks." Like, our Renderers, for example. So, we're just pumping, we're just pumping information into that thing, into that Renderer, right?
https://developer.apple.com/videos/play/wwdc2015/408/?time=2643
Dave Abrahams (Crusty)