---
layout: post
status: publish
published: true
title: Implementing NSCopying (or NSCopyObject() considered harmful)
author: Rob Napier
author_login: rnapier
author_email: robnapier@gmail.com
author_url: http://robnapier.net
excerpt: '`NSCopying` is not always as simple to implement as you would think. If
  any of your superclasses use NSCopyObject(), implementing -copyWithZone: in the
  obvious ways will lead to confusing crashes. You need to guard against this in an
  unorthodox (yet still canonical) way.'
wordpress_id: 439
wordpress_url: http://robnapier.net/blog/?p=439
date: 2009-09-04 17:24:05.000000000 -04:00
categories:
- cocoa
tags:
- nscopying
---
`NSCopying` is not always as simple to implement as you would think. Apple has a good [write-up](http://developer.apple.com/mac/library/documentation/Cocoa/Conceptual/MemoryMgmt/Articles/mmImplementCopy.html) discussing the complexities, but let me elaborate. Forgive some ranting digressions. It's important to know how to work around the problems I'm going to discuss, but it's also important to understand how insane it is to have to work around this issue.

First, there's the fairly obvious problem of deep versus shallow copies. If object `foo` has an instance variable `*bar`, should a copy of `foo` have a second pointer to `bar`, or should it have its own copy of whatever `bar` points to? There is no way to answer this question generally; it depends on the nature of the objects.

Most of the time, this can be dealt with fairly easily by implementing the accessors with the correct behavior (retain versus copy), and you wind up with a `copyWithZone:` like this:

    - (id)copyWithZone:(NSZone *)zone
    {
        Product *copy = [[[self class] allocWithZone: zone] init];
        [copy setProductName:[self productName]];
        return copy;
    }

That works really well as long as your superclass doesn't implement `NSCopying`, but if it does, you may not have enough information or access to cleanly copy it. Now you would think this would be easy:

    - (id)copyWithZone:(NSZone *)zone
    {
        Product *copy = [super copy];
        [copy setProductName:[self productName]];
        return copy;
    }

But that may or may not work. If `super` implements `-copyWithZone:` as described above, then all is fine. But what if your superclass uses `NSCopyObject()`? Things go badly, and in ways very difficult to understand and debug. <a id="more"></a><a id="more-439"></a>`NSCopyObject()`, in my opinion, is evil. Yes it's quick and easy to use, but it's incredibly dangerous and there are better ways (I'll discuss one approach later). Never use this function in your own code. But Apple used it in `NSCell`, and so we have to deal with it. `NSCopyObject()` breaks object orientation (it forces subclasses to know implementation details of their superclass) and memory management (it breaks retain counts).

`NSCopyObject()` makes a perfect copy of an object's ivars, optionally expanding the size of the resulting copy. By "perfect copy" I mean "copies the pointers in the ivars to the new object." So this is what happens in our example above:

    - (id)copyWithZone:(NSZone *)zone
    {
        // Assume -productName = someProduct
        // We'll call this point [1]. 
        Product *copy = [super copy];		// [2]
        [copy setProductName:[self productName]];	// [3]
        return copy;
    }

At point [1], `productName` is pointing to `someProduct`, which has some positive retain count. At point [2], `copy`'s `productName` also points to the same object, but the retain count has not changed. It does not matter how `-setProductName:` is implemented because this isn't called. `NSCopyObject()` has just copied the raw pointer.

At [3], we call `[copy setProductName:...]`, which will likely `[productName release]`. Remember that `copy->productName` points to `someProduct` at this point, so we just reduced this retain count by 1. That might deallocate `someProduct` immediately, or it might not. Then we'll `[newValue retain]` (`newValue` also points to `someProduct`), either crashing immediately, or setting the retain count back up by one, equal to its original value. **But we now have an extra object pointing to it!**

So what do we do? Well, the problem is that `NSCopyObject()` copied pointers without changing the retain counts. So before we mess with the retain counts, we need to clear out those pointers. Here is the canonical way to solve this problem. It's terrible ObjC, but it is the "correct" way to solve Apple's bug:

    - (id)copyWithZone:(NSZone *)zone
    {
        Product *copy = [super copy];

        copy->productName = nil;
        [copy setProductName:[self productName]];

        return copy;
    }

That `->` is dereferencing the `struct*` that underlies `id`. This bypasses all accessors and modifies the underlying ivar. You should never do this, but here it's the best way. The other solution would be to randomly call `[[copy productName] retain]`, but that's even more confusing and error-prone.

If you don't do this, when your two objects deallocate they'll over-release `someProduct`, and you'll crash. And you will be dumbfounded by the crash because all of your memory management will be correct. You'll spend a few hours before hopefully Google brings you to a page like this one.

Since it is a private implementation detail whether a class uses `NSCopyObject()`, you must assume that any class you don't control might, and so you should implement `-copyWithZone:` as above in all cases that your superclass implements `NSCopying`. Even if all the relevant superclasses are yours, you want to implement as above in case you ever change the superclass of your top-level class (which is itself an implementation detail and your subclasses shouldn't rely on). This problem exists for *all* decedents of the class that uses `NSCopyObject()`, not just the first subclass. Your parent class can't fix it for you.

I am horrified that `NSCopyObject()` has been carried over to iPhone. They've been so good about cleaning up these kinds of things. I understand the desire for a fast and easy copy, but there are better ways. `objc_object` is a struct of ivars. We could have a fast memory copy of all the ivars for the *current* class. The rest of the struct could have been initialized to NULL as usual. If this sounds complex it should be as simple as calling `class_getInstanceSize()` for your parent, adding that to `self` to get your first ivar's offset, and `memcpy()` the number of bytes for your `class_getInstanceSize()` minus your superclass's. Then you could clean up your own retain counts without screwing up your subclasses. Even better, multiple sub-classes could use this fast-copy without impacting each other, versus `NSCopyObject()` which can only be use by the top-level class.
