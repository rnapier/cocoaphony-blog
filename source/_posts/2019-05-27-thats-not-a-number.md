---
layout: post
title: "Protocols IV: That's not a number"
---

So far in this series, I've [created a simple APIClient]({% link _posts/2019-04-20-start-with-a-protocol.markdown %}) that can fetch any Fetchable type and decode it from a specific API, and then [extracted a Transport protocol]({% link _posts/2019-04-29-a-mockery-of-protocols.md %}) to abstract away the network layer. In this part, I'll reconsider the top of the stack, the models, and see if I can make those more flexible.
<!-- more -->

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

But now the server API is changing. Document IDs will be Strings, not Ints. (True story.) But really, IDs never really *were* Ints. I mean, IDs aren't *numbers*. What would it mean to add two IDs together? Or divide them? How can I pretend that an ID is a kind of number if most number-like operations would be nonsense? The current design allows me to pass document IDs when I mean user IDs. It even lets me pass random integers when I mean an ID. That can't be right. IDs are their own thing. They want a type.

As usual, I'll start very concretely with User and see if anything generic develops. The first step is to lift the ID into its own type.

<style>
    .chl { color: yellow; } /* code highlight */
</style>

<pre>
struct User: Codable, Hashable {
    <span class="chl">struct ID: Codable, Hashable { 
        let value: Int 
    }
    let id: ID</span>
    let name: String
}
</pre>

So now creating a User looks like this:

```swift
let user = User(id: User.ID(value: 1), name: "Alice")
```

That's ok, but I don't like the `value:` label. It violates one of the principles of the [API Design Guidelines](https://swift.org/documentation/api-design-guidelines/#argument-labels):

> In initializers that perform value preserving type conversions, omit the first argument label, e.g. `Int64(someUInt32)`.

To comply, I should I add another initializer.

<pre>
struct User: Codable, Hashable {
    struct ID: Codable, Hashable { 
        let value: Int 
        <span class="chl">init(_ value: Int) { self.value = value }</span>
    }
    let id: ID
    let name: String
}

let user = User(id: <span class="chl">User.ID(1)</span>, name: "Alice")
</pre>

Much better. Document will be almost exactly the same.

<pre>
struct Document: Codable, Hashable {
    struct ID: Codable, Hashable {
        let value: <span class="chl">String</span>
        init(_ value: <span class="chl">String</span>) { self.value = value }
    }
    let id: ID
    let title: String
}
</pre>

It's not a lot of code, but anytime I'm tempted to cut and paste, it's time to wonder if there's generic code hiding in there. After all, most of the model types in this system will probably have an ID.

## Maybe a protocol?

When I see code duplication, I often reach first for a protocol so I can extract a generic algorithm. That's something protocols are very good at. In the case of ID, there are two duplicated concepts: identifiers conform to Codable and Hashable, and identifiers have a "no label" initializer.

{% pullquote %}
{" It's important to focus on the duplication of concepts, not keystrokes. "} [DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) doesn't mean "never type the same letters twice." The point is to extract things that will *vary together*. I don't want to capture "types that include the characters `: Codable, Hashable` and `init(_...`." I want to capture "things that behave as identifiers." So I'm going to capture that concept as Identifier:
{% endpullquote %}

```swift
protocol Identifier: Codable, Hashable {
    associatedtype Value: Codable, Hashable
    var value: Value { get }
    init(value: Value)
}

extension Identifier {
    init(_ value: Value) { self.init(value: value) }
}
```

With that, User.ID is simplified to:

<pre>
struct User: Codable, Hashable {
    <span class="chl">struct ID: Identifier { let value: Int }</span>
    let id: ID
    let name: String
}
</pre>

To use it, `APIClient.fetch` needs to accept an ID type rather than an Int:

<pre>
func fetch&lt;Model: Fetchable&gt;(_ model: Model.Type, <span class="chl">id: Model.ID</span>,
                             completion: @escaping (Result&lt;Model, Error&gt;) -&gt; Void)
</pre>

And of course Fetchable needs to add an ID type:

<pre>
protocol Fetchable: Decodable {
    <span class="chl">associatedtype ID: Identifier</span>
    static var apiBase: String { get }  // The part of the URL for this fetchable type
}
</pre>

Wait a minute... There's nothing "of course" about that last change. Fetchable used to be a simple protocol. Now it's a PAT (protocol with associated type). That's a big change in Swift. Whenever you find yourself typing `associatedtype`, you need to stop for a moment and think "would I ever want to put this in an Array?" Once you put an associated type on a protocol in Swift today, it's no longer a "thing." It's only a constraint that can be used for extensions and generic functions. It can't put put in a variable, or be passed to a function, or in any other way be treated as a value.

Yes, someday [generalized existentials]({% link _posts/2019-05-12-existential-spelling.md %}) will improve this in some cases. But before you pine for those days, or reach for a [type-eraser]({% link _posts/2015-08-04-erasure.markdown %}), it's time to think harder about the protocol.

## What's the next line of code?

I want to roll back to the Identifier protocol and ask that question, "would I ever want to put an Identifier in an Array?" I've used this protocol in production projects for a long time now, and the answer so far has been no. It just hasn't come up. As I wrote this article, I tried to invent use cases that needed an Array of Identifiers, and each time the example kind of fell apart. I was always forcing it. But it's worth walking through the thought process anyway.

If I try to create an Array of Identifiers today, it spits out that infamous error:

```swift
let ids: [Identifier] = [User.ID(1), Document.ID("password")]
// Protocol 'Identifier' can only be used as a generic constraint because it has Self or associated type requirements
```

And this it the point where you cry out "generalized existential!" But that wouldn't actually change anything. Let's just imagine that we have a generalized existential or I've written an AnyIdentifier type-eraser. Eventually I'm going to wind up with some loop over `ids`:

```swift
for id in ids {
    // ??? the only property is .value, which is an unknown type ???
}
```

I call this the "what now?" problem. The only thing I can do with `id` is get its value, because that's the only thing in the protocol. But each ID can have a different value type. So what can I do with it? Even with the fabled generalized existential, the type of `.value` would have to be Any. What else could it be? I can't call `fetch` with that. I don't even know the Model type.

{% pullquote %}
"I don't even know the Model type." As I said, I've used this protocol in several projects and I've never needed a list of Identifiers, but as soon as I started writing this article, I realized how weird it is that an Identifier doesn't know what type it identifies. Originally I was going to just rewrite this article to ignore it, but these kinds of...mistakes?...are important to explore. I hesitate to call it a mistake, because it's never mattered in any shipping software I've worked on. {" If a type is solving your problems, it's not wrong. "} But maybe it could be better.
{% endpullquote %}

## When you think about it, everything's a function.

Before I make it better, I want to show how to solve a "what now?" problem *without* changing Identifier. I know that sounds a little strange, but sometimes you inherit types that you can't easily change, and it's good to have lots of tools in your belt that don't require rewriting half your project every time something is less than ideal. So let me walk through an example where you think you want to use an Array of Identifiers, but don't.

Let's say that once an hour I want to refresh all the model objects by re-fetching them. So I build a list of Identifiers to refresh, and get the "can only be used as a generic constraint" error, and now have to decide what to do. The answer is to look again at what I really want. I don't want a list of *Identifiers*. I want a list of *refresh requests*. A refresh request is a future action, and a future action is closure. I typically like to wrap that closure into a type. Maybe something specialized to this problem like:


```swift
struct RefreshRequest {
    // The delayed action to perform.
    let perform: () -> Void

    init<Model: Fetchable>(id: Model.ID,
                           with client: APIClient = APIClient.shared,
                           updateHandler: @escaping (Model) -> Void,    // On success
                           errorHandler: @escaping (Model.ID, Error) -> Void = logError) // On failure, with a default
    {
        // Smash together updateHandler and errorHandler into a single () -> Void.
        perform = {
            client.fetch(Model.self, id: id) {
                switch $0 {
                case .success(let model): updateHandler(model)
                case .failure(let error): errorHandler(id, error)
                }
            }
        }
    }

    // Just a helper so errorHandler can have a default value
    static func logError<ID: Identifier>(id: ID, error: Error) {
        print("Failure fetching \(id): \(error)")
    }
}

let requests = [
    RefreshRequest(id: userID, updateHandler: { users[$0.id] = $0 }),
    RefreshRequest(id: documentID, updateHandler: { documents[$0.id] = $0 }),
]
```

{% pullquote %}
The point of all of this isn't this specific data structure. It's that `() -> Void` is an incredibly powerful and flexible type, and you can construct it from all kinds of other functions. It's another case of "common currency." If you want a delayed action, that's just a function. A lot of complicated generic code comes from trying to keep track of all the parameters to a generic function you intend to call later. {" You don't need to keep track of parameters (and their types) if all you need is the function itself. "} This is the heart of *type-erasure* rather than focusing on *type-erasers*. It's hiding types I don't care about any more, like Model. Note in this example how two generic closures that rely on Model (`updateHandler` and `errorHandler`) are combined into a single `() -> Void`, non-generic closure that relies on nothing. This is very common technique, and it'll come up again in this series.
{% endpullquote %}

There are more improvements I could make here. The basic closure `{ someModel[$0.id] = $0 }` is going to be duplicated a lot and I could fix that. But I'm going to leave it for now and focus on a better identifier.

## A Real Identifier

What I really want is the model type to know its ID type, and the ID type to know its model type. If you remember the `APIClient.fetch` method, it takes both a type and an identifier:

<pre>
func fetch&lt;Model: Fetchable&gt;(_ model: <span class="chl">Model.Type</span>, id: <span class="chl">Model.ID</span>,
                             completion: @escaping (Result<Model, Error>) -&gt; Void)
</pre>

This creates awkward repetition in the API:

<pre>
client.fetch(<span class="chl">User</span>.self, id: <span class="chl">User</span>.ID(1), completion: { print($0)} )
</pre>

I could add an extra "Model" associated type to the Identifier protocol, but it gets a bit messy. Some of it is just Swift syntax (`where` clauses and the like), but it really comes down to Identifier not being a very good protocol. Look at the implementations:

```swift
struct User.ID: Identifier { let value: Int }
struct Document.ID: Identifier { let value: String }
```

{% pullquote %}
If you think about any other implementations, they're going to be almost identical: a struct with a single property called `value`. It's hard to imagine any other way you'd want to implement this protocol. {" If every instance of a protocol conforms in exactly the same way, it should probably be a generic struct. "}
{% endpullquote %}


```swift
// An identifier (of some Value type) that applies to a specific Model type
struct Identifier<Model, Value>: Codable, Hashable where Value: Codable & Hashable {
    let value: Value
    init(_ value: Value) { self.value = value }
}
```

Identifier has two type parameters. The Model is the type this identifier applies to. The Value is the kind of identifier it requires (Int, UInt64, String, etc). The Model isn't actually used anywhere, but it means that `Identifier<User, Int>` and `Identifier<Document, Int>` are completely different types and can't be mixed up.

So User becomes:

<pre>
struct User: Codable, Hashable {
    <span class="chl">let id: Identifier&lt;User, Int&gt;</span>
    let name: String
}
</pre>

That's ok, but it'd be nicer to typealias it so I can refer to User.ID as a type:

<pre>
struct User: Codable, Hashable {
    <span class="chl">typealias ID = Identifier&lt;User, Int&gt;
    let id: ID</span>
    let name: String
}
</pre>

And it can be even a little nicer if I extract a protocol, and apply it to Fetchable:

```swift
// Something identified with an Identifier
protocol Identified {
    associatedtype IDType: Codable & Hashable
    typealias ID = Identifier<Self, IDType>
    var id: ID { get }
}

// Any model type, just to simplify the signatures
protocol ModelType: Identified, Codable, Hashable {}

// Something that can be fetched from the API by ID
protocol Fetchable: Identified {
    static var apiBase: String { get }  // The part of the URL for this fetchable type
}

// User model object
struct User: ModelType {
    typealias IDType = Int
    let id: ID
    let name: String
}

extension User: Fetchable {
    static var apiBase: String { return "user" }
}
```

And finally, `fetch` doesn't need any type parameters. The only thing that could be fetched with a User.ID is a User:

```swift
func fetch<Model: Fetchable>(_ id: Model.ID,
                             completion: @escaping (Result<Model, Error>) -> Void)

client.fetch(User.ID(1), completion: { print($0)} )
```

## Trials and Witnesses

There are a lot of people who are a lot better than I am at this, and I'm sure they would have built this (or something better!) all at once on the first try. But I'm not bad at this stuff, and this is how it usually works for me. I want to stress that I've shipped the protocol version of Identifier successfully in several products, and have never run into a case where I actually wanted a more powerful Identifier that knew its Model. It's just that by playing around (and thinking a lot about [Brandon Williams'](https://twitter.com/mbrandonw) excellent [Protocol Witnesses](https://www.youtube.com/watch?v=3BVkbWXcFS4) talk) I discovered another approach.

Of course I've never actually shipped this Identified protocol. Maybe I'm wrong. Maybe it has quirks when you try to use it in real code. Maybe it turns out to awkward or limited for some reason. I won't know until I ship it in a production project.

I'll now remind you that stdlib's Collection protocol required [a pretty major overhaul](https://github.com/apple/swift-evolution/blob/master/proposals/0065-collections-move-indices.md) in Swift 3, and tweaks in [Swift 4.1](https://github.com/apple/swift-evolution/blob/master/proposals/0191-eliminate-indexdistance.md) and [Swift 5](https://github.com/apple/swift-evolution/blob/master/proposals/0232-remove-customization-points.md). The stdlib team is *definitely* better at this than I am, and Collection is probably the most foundational and carefully considered protocol in Swift. And still, it's hard to get it right on the first try. (For another major example, see the four iterations of [Protocol-oriented integers](https://github.com/apple/swift-evolution/blob/master/proposals/0104-improved-integers.md).)

Generic code is hard. There are trade-offs. Some things are hard because Swift is still evolving. And some things are hard because generic code is just hard. Build simply and concretely, and extract solutions as you discover problems. Don't invent problems for yourself. "It isn't generic enough" is not a problem. Make sure your generic code is solving a problem you really have, and put it off as long as you can get away with. You'll probably have to redesign it anyway.

Next time I'll move beyond fetching models. There are so many other things an API can do. What would that look like?

[Swift Playground](/assets/protocols/StartWithAProtocol.zip)
