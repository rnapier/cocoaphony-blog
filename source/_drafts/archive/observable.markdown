---
layout: post
title: "Every Move You Make"
comments: true
published: false
categories: 
---

# Some Thoughts on Observable

KVO has about the worst API you can imagine. We know that. [Ben Sandofsky](https://twitter.com/sandofsky) recently [reiterated the well-known issues](https://sandofsky.com/blog/kvo.html), so I won't repeat all that. Swift makes it worse, because KVO requires runtime shenanigans and `AnyObject` and other things that fight Swift's advantages.

So I've been exploring more Swifty approaches to observation. I'm certainly not the first to go down this route, and I'm not even certain if this is the best approach yet, but there are some interesting techniques to explore along the way so that seems worth the discussion. Special thanks to [@followben](https://twitter.com/followben) and [@alextrob](https://twitter.com/alextrob) for their help on the design. I'm anxious to hear others' experiences and input on how to improve it.

This design is based on what seems to work best in Swift as it currently exists, and that introduces a number of tradeoffs that I'll discuss. I expect that Swift 3 (and certainly later versions of Swift) will lead us to new patterns.

# Who You Lookin' At?

There are two major ways to think about observations. One way is to observe an object and filter to some property. This is how KVO does things. You call `addObserver...` on the top-level object, and pass a keypath to indicate which part interests you. The other way is to observe the value itself. This is how Reactive systems work, and the approach I've taken here. That means that the type of the value is `Observable<Wrapped>`. This means 
