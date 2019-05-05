---
layout: post
title: "Protocols III: That's not a number"
---

So far in this series, I've [created a simple APIClient]({% link _posts/2019-04-20-start-with-a-protocol.markdown %}) that can fetch any Fetchable type and decode it from a specific API, and then [extracted a Transport protocol]({% link _posts/2019-04-29-a-mockery-of-protocols.markdown %}) to abstract away the network layer. In this part, I'll reconsider the top of the stack, the models, and see if I can make those more flexible.

The current models are User and Document:

```swift
struct User: Codable, Hashable {
    let id: Int
    let name: String
}

struct Document: Codable, Hashable {
    let id: Int
    let title: String
}
```

But now I've learned that the API is changing. Document IDs will be Strings, not Ints. (True story.) But really, IDs were never *really* Ints. I mean, IDs aren't *numbers*. What would it mean to add two IDs together? Or divide them? How can I pretend that an ID is a kind of number if most number-like operations would be nonsense? The current design allows me to pass document IDs when I mean a user ID. It even lets me pass an Array count when I mean a user ID. That can't be right. IDs are their own thing. They want a type.

As usual, I'll start very concretely with User, and I'll see if anything generic develops. The first step is to lift the ID into its own type.

```swift
struct User: Codable, Hashable {
    struct ID: Codable, Hashable {
        let value: Int
    }
    let id: ID
    let name: String
}
```

That's ok. It leads to this kind of syntax when creating a user:

```swift
let user = User(id: User.ID(value: 1), name: "Alice")
```

That's ok, but I don't like the `value:` label. It violates one of the principles of the [API Design Guidelines](https://swift.org/documentation/api-design-guidelines/#argument-labels):

> In initializers that perform value preserving type conversions, omit the first argument label, e.g. `Int64(someUInt32)`

To comply, I should I add an init:

<style>
    .chl { color: yellow; } /* code highlight */
</style>

<pre>
struct User: Codable, Hashable {
    let id: ID
    let name: String
}

let user = User(id: <span style="chl">User.ID(1)</span>, name: "Alice")
</pre>

Much better. Document will be almost exactly the same.

<pre>
struct Document: Codable, Hashable {
    struct ID: Codable, Hashable {
        let value: <span style="chl">String</span>
        init(_ value: <span style="chl">String</span>) { self.value = value }
    }
    let id: ID
    let title: String
}
</pre>

It's not a lot of code, but anytime I'm tempted to cut and paste, it's time to wonder if there's generic code hiding in there. Afterall, most of the model types in this system will probably have an ID.

One obvious approach would be a struct generic over the value type:

```swift
// Not a good idea
struct ID<Value>: Codable, Hashable
    where Value: Codable & Hashable
{
    let value: Value
    init(_ value: Value) { self.value = value }
}
typealias UserID = ID<Int>
```

But this isn't a good idea. One of the main points of creating the ID type was to keep the IDs straight. With this struct, I can still mix up any IDs that have the same storage. I don't want "an Int ID." I want "a User ID."

How about a protocol? It's tempting (tempting enough that it's how I've done this for a long time), but it's not ideal. Even so, I'll walk through how to implement it, and then discuss the problems.

```
protocol IDType: Codable, Hashable {
    associatedtype Value: Codable, Hashable
    var value: Value { get }
    init(value: Value)
}
```

In order to conform to IDType, a type needs to be Codable and Hashable, and it needs an init that takes a value. Those are all things that Swift will automatically synthesize for us, so they’re free. And then, types that conform to IDType get this no-label initializer as an extension:

```
extension IDType {
    init(_ value: Value) { self.init(value: value) }
}
```

And finally, User can use IDType:

<pre>
// User model object
struct User: Codable, Hashable {
    <span style="chl">struct ID: IDType { let value: Int }</span>
    let id: ID
    let name: String
}
</pre>

This shows one of the main things PATs are good for: adding extra methods to existing types.

## Protocols grant superpowers

