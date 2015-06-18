---
layout: post
title: "noescape"
comments: true
published: false
categories: 
---

But what's `@noescape`? That's a promise to the compiler (and the caller) that
we aren't going to hold onto this closure. That means we promise we're not going
to create a retain loop. The compiler checks our work. If we do something that
*might* hold onto the closure, we'll get a compiler error. For example:

```
func sneaky<T,U>(f: (T) -> U) {}  // f isn't marked @noescape

extension Array {
    func mymap<T>(@noescape transform: (Generator.Element) -> T) -> [T] {
        sneaky(transform) // Invalid use of non-escaping function in escaping context 'T'->'U'
        var ts: [T] = []
        for x in self {
            ts.append(transform(x))
        }
        return ts
    }
}
```

We need to be careful when we pass closures because they might capture objects
that create to a retain loop. If we're just going to use the closure and throw
it away, we should mark it @noescape so the compiler knows that.

If you've been paying close attention, you might ask "does that mean `@noescape`
creates a type?" No, it's an attribute. You can show that by trying to overload
based on it:

```
func sneaky<T,U>(f: (T) -> U) {}
func sneaky<T,U>(@noescape f: (T) -> U) {} // Invalid redeclaration of 'sneaky'
```

If `(T)->U` were a different type than `@noescape (T)->U`, then we could do
that. But the closure isn't @noescape. The *parameter* is.
