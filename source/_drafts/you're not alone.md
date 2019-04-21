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
