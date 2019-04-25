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

For a couple of years, I was rather annoyed at the phrase "protocol-oriented programming." If by "protocol" you just mean "interface," then Go is much more "protocol oriented" than Swift. But the more I've wrestled with this new paradigm, the more I realized that POP isn't really about the protocols. It's about the extensions. But "extension-oriented programming" would be an even worse name. And more than just extensions, it's really, deeply, about generic algorithms. And "algorithm-oriented programming," well, aren't we all?

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

In the next several articles, I'll be developing a very common system, a general-purpose networking stack that can fetch data asynchronously and decode arbitrary types. You may have built a system like this yourself in Swift. You may have used a framework that does it. The point of this exercise isn't really the end result (though I think it's quite useful code), but the process. What questions should you ask, and when, and how do you know what good answers look like? And most importantly, how does this "protocol-oriented" thing guide us? How is it different than other approaches?

So to get started, I want to show a common starting point that never goes well for me. I've tried to build it this way several times myself, and I always find myself in a corner eventually. I see a lot of other people make this same mistake.

```swift
// This will not go well.
// Trying to model a Request as something that can fetch and parse a Response.
protocol Request {
    associatedtype Response
    func parse(data: Data) throws -> Response
    var urlRequest: URLRequest { get }
}
```

How do I know this won't go well? I'll discuss it much more in depth later, but Request is a protocol with associated type (PAT). Any time you create a PAT, you should ask yourself "will I ever want to put this in an Array?" If the answer is yes, you don't want a PAT. Requests are certainly something you'd want to put in an Array. Lists of pending requests, lists of requests that need to be retried, request priority queues. There are lots of reasons to put a Request in an Array.

You might be tempted to look for a work-around, but don't. Type-eraser? No. Generalized Existential?!?! ...no... Even if you find some "work-around" to the problem at hand you'll run into other walls very quickly (and I've seen that again and again). That "can only be used as a generic constraint" is telling you something important. This isn't a problem with Swift. This just isn't what PATs are for. There are other tools for this problem. We'll get to what PATs are for soon, but the basic problem here is starting with a protocol before we even know what algorithm we want to write.

So what does "know the algorithm" look like in practice?

## Start concrete

A good way to find a generic algorithm is to start with several concrete algorithms, and then make a parameter out of what varies. In this case, we want to fetch a several model types from an API and decode them. In order to start concretely, I'll make some actual types.

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

This may not be our final implementations, but they're pretty solid to get started. They're pretty similar, but not identical, and that's ok for the first pass. 

I also want a client to manage my connection to the server. I'm marking classes "final" to remind you that I'm not planning on using any class inheritance. I'm not suggesting you need to include "final" on all your class definitions. It's not usually necessary. I'm making it a reference type because it's possible that in the future it would state, and that would be confusing as a value type. For example, if a login step were required, I'd want all references to the client to be logged in together.

```swift
final class APIClient {
    let baseURL = URL(string: "https://www.example.com")!
    let session = URLSession.shared

    // ... methods to come ...
}
```

And now I want the code to fetch and decode a User, as a method on APIClient

```swift
func fetchUser(id: Int,
               completion: @escaping (Result<User, Error>) -> Void)
{
    let urlRequest = URLRequest(url: baseURL
        .appendingPathComponent("user")
        .appendingPathComponent("\(id)")
    )

    session.dataTask(with: urlRequest) { (data, _, error) in
        if let error = error { completion(.failure(error)) }
        else if let data = data {
            completion(Result {
                try JSONDecoder().decode(User.self, from: data)
            })
        }
        }.resume()
}
```

 I’m sure you’ve all written code kind of like this a hundred times. Construct an URLRequest. Fetch it. Parse it. Pass it to the completion handler. Now, what does the code for `fetchDocument` look like?

<style>
    .chl { color: yellow; } /* code highlight */
    .cer { color: red; } /* code error */
</style>

<pre>
func fetch<span class="chl">Document</span>(id: Int,
               completion: @escaping (Result<<span class="chl">Document</span>, Error>) -> Void)
{
    let urlRequest = URLRequest(url: baseURL
        .appendingPathComponent(<span class="chl">"document"</span>)
        .appendingPathComponent("\(id)")
    )

    session.dataTask(with: urlRequest) { (data, _, error) in
        if let error = error { completion(.failure(error)) }
        else if let data = data {
            completion(Result {
                try JSONDecoder().decode(<span class="chl">Document</span>.self, from: data)
            })
        }
        }.resume()
}
</pre>

Unsurprisingly, `fetchDocument` is almost identical to `fetchUser` except for four changes. The function name, the type to pass to the closure, the URL path, and the type to decode. It's so similar because I copied and pasted it. And when you find yourself copying and pasting, that's where you know there's going to be reusable code. So I extract that into a generic function:

```swift
func fetch<Model: Decodable>(_: Model.Type, id: Int,
                             completion: @escaping (Result<Model, Error>) -> Void)
{
   ...
}
```

Before going on, it's worth exploring the signature. Notice that I pass the type of Model as a parameter. It doesn't even need a name, because the value isn't used. It's just there to nail down the type. Doing it that way makes type inference a lot nicer. Consider JSONDecoder's `decode` method. It's called this way:

<pre>
let value = try JSONDecoder().decode(<span class="chl">Int.self</span>, from: data)
</pre>

Now, it could have been designed this way instead:

<pre>
let value<span class="chl">: Int</span> = try JSONDecoder().decode(data)
</pre>

I would have even been a little shorter that way. But it doesn't scale as well. When you force the caller to insert type information, it can create a lot of headaches when things get more complicated, and it makes the compiler errors much harder to understand. So make sure that every type parameter shows up in a function parameter, rather than just the type of the return value or something in a closure.

Implementing `fetch` is pretty straightforward, except for one small problem:

<pre>
func <span class="chl">fetch&lt;Model&gt;(_ model: Model.Type,</span>
                  id: Int,
                  completion: @escaping (Result<<span class="chl">Model</span>, Error>) -> Void)
{
    let urlRequest = URLRequest(url: baseURL
        .appendingPathComponent(<span class="cer">"??? user | document ???"</span>)
        .appendingPathComponent("\(id)")
    )

    session.dataTask(with: urlRequest) { (data, _, error) in
        if let error = error { completion(.failure(error)) }
        else if let data = data {
            completion(Result {
                try JSONDecoder().decode(<span class="chl">Model</span>.self, from: data)
            })
        }
        }.resume()
}
</pre>

There's this string that’s either "user" or "document". That’s something that changes that isn’t part of Decodable. So Decodable isn’t powerful enough to implement this algorithm. I need a new protocol.

```swift
protocol Fetchable: Decodable {
    static var apiBase: String { get }
}
```

I need a protocol that requires first, that the type be Decodable, and also requires that it provide this extra string, `apiBase`. <!-- (See [Protocols do not conform]() for more on the difference between "*requires* Decodable" and "*is* Decodable.") --> With that, I can finish writing `fetch`:

<pre>
func fetch&lt;Model&gt;(_ model: Model.Type,
                  id: Int,
                  completion: @escaping (Result<Model, Error>) -> Void)
{
    let urlRequest = URLRequest(url: baseURL
        .appendingPathComponent(<span class="chl">Model.apiPath</span>)
        .appendingPathComponent("\(id)")
    )

    session.dataTask(with: urlRequest) { (data, _, error) in
        if let error = error { completion(.failure(error)) }
        else if let data = data {
            completion(Result {
                try JSONDecoder().decode(Model.self, from: data)
            })
        }
        }.resume()
}
</pre>

## Retroactive modeling

Now to use it, I need to make User and Document conform to Fetchable.

```swift
extension User: Fetchable {
    static var apiBase: String { return "user" }
}

extension Document: Fetchable {
    static var apiBase: String { return "document" }
}
```

These tiny extensions represent one of the most powerful, and easiest to overlook, aspects of protocol-oriented programming: retroactive modeling. It is quite non-obvious that I can take a type like User that wasn’t designed to be Fetchable, and make it Fetchable in an extension. And that extension doesn’t even have to be in the same module. That's not something you can typically do with class inheritance. You need to choose a superclass when you define a type. While it's somewhat similar to Ruby-style mix-ins, 

I can take any type you want and conform it to your own protocols to let it be used in new and more powerful ways. There’s no need to tie User to this one use case and this one API.
Of course you have to be a little careful about how you name your protocol properties, or you could have collisions, but this is a great example of how Swift lets you adapt types to use cases as you need them, rather than having to decide everything in the definition.

## First checkpoint

I know this has been basic so far. I know many of you "know all this." The point of this exercise is not what was built, but how it was built. I started with simple, concrete code, and extracted first a generic function, and then a simple (without associated type) protocol. This is exactly the opposite of starting with a Request protocol that includes an associated type. This was just the first step. This system is nowhere near as flexible and powerful as it could be, but already it's meeting the goal I set at the beginning: "fetch a several model types from an API and decode them." Keep the goal in mind and don't let the protocols get out in front of you.

Next time, I'll push this example further, and start seeing what protocol oriented programming can really accomplist.