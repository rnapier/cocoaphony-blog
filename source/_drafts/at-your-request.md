---
layout: post
title: "Protocols V: At Your Request"
---
So, back to our [APIClient]({% link _posts/2019-04-20-start-with-a-protocol.markdown %}). When last [I left off]({% link _posts/2019-05-27-thats-not-a-number.md %}), I had the following client code:

```swift
final class APIClient {
    static let shared = APIClient()
    let baseURL = URL(string: "https://www.example.com")!
    let transport: Transport

    init(transport: Transport = URLSession.shared) { self.transport = transport }

    // Fetch any Fetchable type given an ID, and return it asynchronously
    func fetch<Model: Fetchable>(_ id: Model.ID,
                                 completion: @escaping (Result<Model, Error>) -> Void)
    {
        // Construct the URLRequest
        let url = baseURL
            .appendingPathComponent(Model.apiBase)
            .appendingPathComponent("\(id)")
        let urlRequest = URLRequest(url: url)

        // Send it to the transport
        transport.send(request: urlRequest) { data in
            let result = Result { try JSONDecoder().decode(Model.self, from: data.get()) }
            completion(result)
        }
    }
}
```

This `fetch` method is great for getting a model by ID, but I have other things I want to do. For example, I'd like to periodically POST to /keepalive and return if there's an error. That's really similar, but kind of different.
<!-- more -->

<pre style="float: left; width: 45%; min-width: 450px">
// GET /&lt;model&gt;/&lt;id&gt; -&gt; Model
func fetch&lt;Model: Fetchable&gt;(
    _ id: Model.ID,
    completion: @escaping (Result&lt;Model, Error&gt;) -&gt; Void)
{<span style="color: yellow;">
    let urlRequest = URLRequest(url: baseURL
        .appendingPathComponent(Model.apiBase)
        .appendingPathComponent(&quot;\(id)&quot;)
    )</span>

    transport.fetch(request: urlRequest) {<span style="color: cyan">
        data in
        completion(Result {
            let decoder = JSONDecoder()
            return try decoder.decode(
                Model.self,
                from: data.get())
        })</span>
    }
}
</pre>


<pre style="width: 45%;">
// POST /keepalive -&gt; Error?
func keepAlive(
    completion: @escaping (Error?) -&gt; Void)
{<span style="color: yellow;">
    var urlRequest = URLRequest(url: baseURL
        .appendingPathComponent("keepalive")
    )
    urlRequest.httpMethod = "POST"</span>

    transport.send(request: urlRequest) {<span style="color: cyan">
        switch $0 {
        case .success: completion(nil)
        case .failure(let error): 
             completion(error)
        }</span>
    }
}
</pre>

<div style="clear: both;"></div>

Both basically follow this pattern of build an URL request, pass it to transport, and then deal with the result. I know it’s just one line that exactly duplicates, but the structure is still really similar, and it feels we could pull this apart. The problem is that `fetch` is doing too much.

So maybe we pull out the part that changes and call it Request. But what should Request be? So often, I see people jump to a PAT (protocol with associated type) like this:

```swift
// This is a bad idea
protocol Request {
    var urlRequest: URLRequest { get }
    associatedtype Response
    var completion: (Result<Response, Error>) -> Void { get }
}
```

So what's the question we ask whenever we make a PAT? Would I ever want an array of these? I think we would definitely want an array of requests. A list of pending requests. Chaining requests together. Requests that should be retried. We definitely want an array of requests. This is a great example where someone might come along as say, if only we had [generalized existentials]({% link _posts/2019-05-12-existential-spelling.md %}) then everything would be wonderful. No. That wouldn't fix anything. The problem is this treats a PAT like a generic, which isn't the right way to think about it.

### PATs are not "generic protocols" (or at least not in the way you're thinking)

Generics and PATs are very different things that solve very different problems. Generics are type-parameterization. That means that the types are being passed as parameters to the function. They're passed at compile time, but they're still passed by the caller. When you say `Array<Int>`, you, the caller, get to decide what kinds of elements Array holds. In `Array<Int>(repeating: 0, count: 10)
`, Int is just as much a parameter as 0 and 10. It's just a different kind of parameter.

PATs aren't like that. Their associated types are not parameters passed by the caller. They're hooks provided by the implementor of the conforming type (or whoever wrote the conforming extension). When you conform a type to a PAT, you have to provide a mapping of stuff that algorithms need to stuff this type has. Collection requires an Index type in order to implement subscripts (among other things). Set says "here's my Set.Index type that Collection algorithms should use when you need an Index type." Array says "please use Int as my Index for those algorithms." As the consumer of Set or Array, you can't change those choices. You can't say "I want an Array indexed by Character." That's not up to you. It's not a type parameter.

The point of a PAT is to allow algorithms to use the type. If you're thinking about storage (like putting things in an Array) rather than algorithms, you probably do not want a PAT.

### First use it, then build it

Rather than focusing first on how to construct a Request, let's focus on how we'd like to *use* one. I wish something would just know all the stuff I needed to send to the transport....

```swift
class APIClient {
    func send(_ request: Request) {
        transport.send(request: request.urlRequest,
                       completion: request.completion)
    }
}
```

This is a kind of ["wish driven development."]({% link _posts/2014-08-17-functional-wish-fulfillment.markdown %}) We "wish" there were some type that could handle the URLRequest and completion handler for us, we pretend it exists, write the code that uses it, and then make it a reality. And the reality couldn't be simpler:

```swift
struct Request {
    let urlRequest: URLRequest
    let completion: (Result<Data, Error>) -> Void
}
```

OK, that's simple, but that's still not quite what we want. There's no model information in there. I want to create Requests that know about model types, like this:

```swift
client.send(Request.fetching(id: User.ID(1), completion: { print($0)} ))
```

So I want to put User.ID into a system and get User back out in the completion handler, but the system (Request) only understands Data. That means we're making a type eraser. We're hiding a type (User) inside Request. How? With one of the simplest type erasers you can have: a generic function or closure. Basically, we just take `fetch` and wrap it into a closure. Here's `fetch`:

```swift
class APIClient {
    func fetch<Model: Fetchable>(_ id: Model.ID,
                                 completion: @escaping (Result<Model, Error>) -> Void)
    {
        // Construct the URLRequest
        let url = baseURL
            .appendingPathComponent(Model.apiBase)
            .appendingPathComponent("\(id)")
        let urlRequest = URLRequest(url: url)

        // Send it to the transport
        transport.send(request: urlRequest) { data in
            let result = Result { try JSONDecoder().decode(Model.self, from: data.get()) }
            completion(result)
        }
    }
}
```

And here's `fetching`:

```swift
extension Request {
    static var baseURL: URL { URL(string: "https://www.example.com")! }

    // GET /<model>/<id> -> Model
    static func fetching<Model: Fetchable>(id: Model.ID,
                                           completion: @escaping (Result<Model, Error>) -> Void) -> Request
    {
        // Construct the URLRequest
        let url = baseURL
            .appendingPathComponent(Model.apiBase)
            .appendingPathComponent("\(id)")
        let urlRequest = URLRequest(url: url)

        return self.init(urlRequest: urlRequest) {  // Here's the closure that hides (erases) Model
            data in
            completion(Result {
                let decoder = JSONDecoder()
                return try decoder.decode(Model.self, from: data.get())
            })
        }
    }
}
```

`fetching` is a generic method, but it returns a non-generic Request struct. This kind of generic->non-generic conversion is an incredibly powerful way to simplify your system and keep generics from spiraling out of control.

You may ask "why a static `fetching` method rather than creating an `init(fetching:completion)` extension" For this one, `init` would probably be fine, but as you think about other kinds of Requests, especially ones with no parameters, it would get messy. For example, it's hard to build a nice `init` for /keepalive. (This isn't a deep design point; it's just a stylistic choice. You might prefer `init(keepAliveWithCompletion:)`, and that's up to you.)

In any case, this is how I'd build the /keepalive handler:

```swift
extension Request {
    // POST /keepalive -> Error?
    static func keepAlive(completion: @escaping (Error?) -> Void) -> Request
    {
        var urlRequest = URLRequest(url: baseURL
            .appendingPathComponent("keepalive")
        )
        urlRequest.httpMethod = "POST"

        return self.init(urlRequest: urlRequest) {
            switch $0 {
            case .success: completion(nil)
            case .failure(let error): completion(error)
            }
        }
    }
}
```

## Wrapping up the network stack

This is the end of my discussion of this little network stack (though not the end of my discussion of generics). It's not designed to be a "real" network stack. I don't expect anyone to use this directly as described. I build stacks based on these principles all the time, but I've never had one look exactly like this. They're each quite specialized to their particular API, and the particular needs of the app. The goal here wasn't to create a general purpose library to solve all networking problems. The goal was to show how you would extract generic code tailored to a problem. Your API is probably different, and you'll probably build your solution in a different way. Don't feel you have to use a Transport and an APIClient and a Request. (Though maybe you should use Transport... :D)

If you want to build a general purpose library around this, I suggest you first build small, custom libraries around several APIs that are very different from each other. Then look for the abstractions. Abstracting too soon, before you really understand the problem, is the most common cause of generic headaches.

There is no such thing as "as generic as possible." Generic code is abstraction, and abstraction is choices. Choosing to make things flexible in one direction often makes it harder to be flexible in another. I have a long list of code bases where we needed more flexibility, and the first step was to rip out all the "flexible" code that made the wrong assumptions about what kind of flexibility would be needed and was never actually used.

> Write concrete code first. Then work out the generics.

If you stick to that, it'll probably work out ok.

[Swift Playground](/assets/protocols/StartWithAProtocol.zip)
