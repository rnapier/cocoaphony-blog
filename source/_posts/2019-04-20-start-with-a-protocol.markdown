---
layout: post
title: 'Protocols I: "Start with a protocol," he said'
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

For a couple of years, I was rather annoyed at the phrase "protocol-oriented programming." If by "protocol" you just mean "interface," then Go is much more "protocol oriented" than Swift. But the more I've wrestled with this new paradigm, the more I realized that protocols are more than just interfaces, and POP isn't deeply about the protocols anyway. It's about the extensions. But "extension-oriented programming" would be an even worse name. And more than extensions, it's really, deeply, about generic algorithms. And "algorithm-oriented programming," well, aren't we all?

Naming a paradigm is always fraught with trouble. Most modern "object-oriented" languages aren't object-oriented at all. They're class-oriented (vs Smalltalk and JavaScript). And most "functional programming" languages are mostly value-oriented (vs FP and point-free). But the point of the names is shorthand for concepts bigger than a word, so let's not get too caught up on the "protocol" in protocol-oriented programming. The Holy Roman Empire was in no way holy, nor Roman, nor an empire. Discuss.

## Beware quotes traveling sans context

The famous "start with a protocol" quote is actually the end of a longer paragraph:

> For example, if you want to write a generalized sort or binary search…Don't start with a class. Start with a protocol.

Or as Dave [clarified on Twitter](https://twitter.com/cocoaphony/status/1104114233288151043):

> Use value types, then if you need polymorphism, make them conform to protocols.  Avoid classes.

*If* you're reaching for class inheritance, try a protocol and value type instead. That's very different from "start with a protocol for every problem." [Ben Cohen](https://twitter.com/AirspeedSwift) covered this in much more detail in the WWDC 2018 talk [Swift Generics (Expanded)](https://developer.apple.com/videos/play/wwdc2018/406/). 

> So notice that we considered a varied number of concrete types first. And now, we're thinking about a kind of protocol that could join them all together. And, it's important to think of things as this way around. To start with some concrete types, and then try and unify them with a protocol.

{% pullquote %}
If you take away just one thing from this series, I want it to be this: *{" Write concrete code first. Then work out the generics. "}* Start with concrete types and clear use cases, and find the places that duplication happens. Then find abstractions. The power of protocol-oriented programming is that you don’t have to decide when you create a type exactly how it will be used. When you use class inheritance, you have to design your class hierarchy very early. But with protocols, you can wait until later.
{% endpullquote %}

When I most get into trouble with protocols is when I try to write code "as generically as possible." That doesn't really mean anything. Abstractions are choices, and when you make a choice to be flexible in one direction, you generally make it harder to be flexible in other directions. Without some clear use cases, you don't know what abstractions make sense.

So today, I want to come to protocol-oriented programming fresh, with a focus on very every-day problems we face when developing iOS apps in Swift.

## Setting the stage

Over the next several articles I'll be developing a very common system, a general-purpose networking stack that can fetch data asynchronously and decode arbitrary types. You may have built a system like this yourself in Swift. You may have used a framework that does it. The point of this exercise isn't really the end result (though I think it's quite useful code), but the process. What questions should you ask, and when, and how do you know what good answers look like? And most importantly, how does this "protocol-oriented" thing guide us? How is it different than other approaches?

I expect that you're somewhat familiar with Swift, and particularly that you understand the syntax of generic functions and types, and have at least seen an `associatedtype` before. If you're just getting started in Swift, maybe bookmark this series for later.

So to get started, I want to show a common starting point that never goes well for me. I've made this mistake many times, and I always find myself in a corner eventually. I see a lot of other people make this mistake, too.

```swift
// A network Request knows the URLRequest to fetch some data, and then can parse it.
// This will not go well.
protocol Request {
    associatedtype Response
    func parse(data: Data) throws -> Response
    var urlRequest: URLRequest { get }
}
```

{% pullquote %}
How do I know this won't go well? I'll discuss it much more in depth later, but Request is a protocol with associated type (PAT). Any time you create a PAT, you should ask yourself "{"will I ever want to put this in an Array?"}" If the answer is yes, you don't want a PAT. Requests are certainly something you'd want to put in an Array. Lists of pending requests, lists of requests that need to be retried, request priority queues. There are lots of reasons to put a Request in an Array.
{% endpullquote %}

You might be tempted to look for a work-around, but don't. Type-eraser? No. Generalized Existential?!?! ...no... Even if you find some "work-around" to the problem at hand you'll run into other walls very quickly (and I've seen that again and again). That "can only be used as a generic constraint" is telling you something important. This isn't a problem with Swift. This just isn't what PATs are for. There are other tools for this problem. In later articles I'll explain why you don't want these work-arounds, but the basic problem is starting with a protocol before we even know what algorithm we want to write.

So what does "know the algorithm" look like in practice?

## Start concrete

A good way to find a generic algorithm is to start with several concrete algorithms, and then make a parameter out of what varies. In this case, I want to fetch several model types from an API and decode them. In order to start concretely, I'll make some actual types.

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

This may not be our final implementations, but they're good enough to get started. They're pretty similar, but not identical, and that's good for the first concrete types. I'll want to push the envelope a bit more later, but this is good enough for now. 

I also want a client to manage my connection to the server. I'm marking classes "final" to remind you that there's no class inheritance here. I'm not suggesting you need to include "final" on all your class definitions. It's not usually necessary. I'm making it a reference type because the client might eventually have some shared state. For example, if a login step were required, I'd want all references to the client to be logged in together.

```swift
final class APIClient {
    let baseURL = URL(string: "https://www.example.com")!
    let session = URLSession.shared

    // ... methods to come ...
}
```

And now I want the code to fetch and decode a User, as a method on APIClient.

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

 I’m sure many of you have written code kind of like this many times. Construct a URLRequest. Fetch it. Parse it. Pass it to the completion handler. Now, what does the code for `fetchDocument` look like?

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

Unsurprisingly, `fetchDocument` is almost identical except for four changes: the function name, the type to pass to the closure, the URL path, and the type to decode. It's so similar because I copied and pasted it. And when you find yourself copying and pasting, that's where I know there's probably some reusable code. So I extract that into a generic function:

```swift
func fetch<Model: Decodable>(_: Model.Type, id: Int,
                             completion: @escaping (Result<Model, Error>) -> Void)
{
   ...
}
```

## Where should type parameters go?

Before going on, it's worth exploring the signature. Notice that I pass the type of Model as a parameter. It doesn't even need a name, because the value won't be used. It's just there to nail down the type parameter in the function's parameters rather than in completion handler's parameters. I'm mostly doing this to show a technique, and because `fetch(2) { ... }` is a bit ambiguous to the reader (since all ID types are Int currently). Sometimes this makes sense, sometimes it doesn't.

A good example where I think it makes a lot of sense is JSONDecoder's `decode` method. It's called this way:

<pre>
let value = try JSONDecoder().decode(<span class="chl">Int.self</span>, from: data)
</pre>

It could have been designed this way instead:

<pre>
let value<span class="chl">: Int</span> = try JSONDecoder().decode(data)
</pre>

It would have even been a little shorter that way. But it forces the caller to add a type annotation on the variable, which is a little ugly, and unusual in Swift. If the only place the type parameter shows up is in the return value, I usually recommend passing it as a parameter. But in any case, try writing some code with it, and focus on making things clear at the call-site. [^1]

[^1]: A previous version of this post advocated for this approach much more strongly, but [some questions on Twitter](https://twitter.com/peres/status/1121824695211429888) made me rethink this.

## Making `fetch` generic

Implementing `fetch` is pretty straightforward, except for one small <span class="cer">problem</span>:

<pre>
func <span class="chl">fetch&lt;Model&gt;(_ model: Model.Type,</span>
                  id: Int,
                  completion: @escaping (Result<<span class="chl">Model</span>, Error>) -> Void)
                  <span class="chl">where Model: Fetchable</span>
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

There's this string that’s either "user" or "document". That’s something that this algorithm requires, but isn’t part of Decodable. So Decodable isn’t powerful enough to implement this. I need a new protocol.

```swift
protocol Fetchable: Decodable {
    static var apiBase: String { get }
}
```

I need a protocol that requires that the type be Decodable, and also requires that it provide this extra string, `apiBase`. <!-- (See [Protocols do not conform]() for more on the difference between "*requires* Decodable" and "*is* Decodable.") --> With that, I can finish writing `fetch`:

<pre>
func fetch&lt;Model&gt;(_ model: Model.Type,
                  id: Int,
                  completion: @escaping (Result<Model, Error>) -> Void)
                  where Model: Fetchable
{
    let urlRequest = URLRequest(url: baseURL
        .appendingPathComponent(<span class="chl">Model.apiBase</span>)
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

These tiny extensions represent one of the most powerful, and easiest to overlook, aspects of protocol-oriented programming: retroactive modeling. It is quite non-obvious that I can take a type like User that wasn’t designed to be Fetchable, and make it Fetchable in an extension. And that extension doesn’t even have to be in the same module. That's not something you can typically do with class inheritance. You need to choose a superclass when you define a type.

I can take any type I want and conform it to my own protocols to use it in new and more powerful ways that the original type creator may never have thought of. There’s no need to tie User to this one use case and this one API. That's why this protocol is called Fetchable rather than something like Model. It *isn't* a "model." It's "something that can be fetched" and it only provides the methods and properties that allow that. I'm not suggesting that you should create a protocol for every use case, just the opposite. Really good protocols are usable by many algorithms. But you want most uses of the protocol to need most of the requirements. If the protocol is just a copy of the type's entire API, it's not doing its job. I'll talk about that more in later articles.

## First checkpoint

I know this has been basic so far. I know many of you "know all this." This article is a warm-up, and the point of the exercise is not *what* was built, but *how* it was built. I started with simple, concrete code, and extracted first a generic function, and then a simple (no associated type) protocol. This is exactly the opposite of starting with a Request PAT and then trying to figure out the callers. This was just the first step. This system is nowhere near as flexible and powerful as it could be, but already it's meeting the goal I set at the beginning: "fetch a several model types from an API and decode them." Keep the current goal in mind and don't let the protocols get out in front of you.

Next time, I'll push this example further, and start seeing what protocol oriented programming can really accomplish. Eventually I'll even need a PAT!

[Swift Playground](/assets/protocols/StartWithAProtocol.zip)

(I don't have comments on this site, but if you're interested in any conversations about it, follow the thread on [Twitter](https://twitter.com/cocoaphony/status/1121549665789411333).)
