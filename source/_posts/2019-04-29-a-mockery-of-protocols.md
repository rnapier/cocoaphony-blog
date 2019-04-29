---
layout: post
title: 'Protocols II: A mockery of protocols'
date: 2019-04-29 11:18 -0400
---
[In the last section]({% link _posts/2019-04-20-start-with-a-protocol.markdown %}), I ended my little network stack at this point:

```swift
// Something that can be fetched from the API
protocol Fetchable: Decodable {
    static var apiBase: String { get }  // The part of the URL for this type
}

// A client that fetches things from the API
final class APIClient {
    let baseURL = URL(string: "https://www.example.com")!
    let session: URLSession = URLSession.shared

    // Fetch any Fetchable type given an ID, and return it asynchronously
    func fetch<Model: Fetchable>(_ model: Model.Type,
                                 id: Int,
                                 completion: @escaping (Result<Model, Error>) -> Void)
    {
        // Construct the URLRequest
        let urlRequest = URLRequest(url: baseURL
            .appendingPathComponent(Model.apiBase)
            .appendingPathComponent("\(id)")
        )

        // Send it to URLSession
        session.dataTask(with: urlRequest) {
            (data, _, error) in
            if let error = error {
                completion(.failure(error))
            }
            else if let data = data {
                let decoder = JSONDecoder()
                completion(Result {
                    try decoder.decode(Model.self,
                                       from: data)
                })
            }
            }.resume()
    }
}
```

This can decode any Fetchable model from an API endpoint that has a URL something like `https://<base>/<model>/<id>`. That's pretty good, but we can do a lot better. A natural first question is "how do I test it?" It relies explicitly on URLSession, which is very hard to test against. A natural approach would be to create a protocol to mock URLSession.

I hope by the time you're done with this series, hearing "create a protocol to mock" makes you flinch just a little.
<!--more-->

{% pullquote %}
The basic premise of a mock is to build a test object that mimics some other object you want to replace. That encourages you to design a protocol that very closely matches the existing interface, and then your "mock object" will also closely match that interface. This makes your "real" object, the protocol, and the mock evolve tightly in lockstep, and it cuts off opportunities for more powerful protocols that aren't tied to one implementation. {" If the only reason you can imagine using a protocol is for testing, then you're not getting all you could out of it. "} Protocols can be so much more.
{% endpullquote %}

So my goal isn't to "mock" URLSession, but to abstract the functionality I need. What I want is to map a URLRequest to Data, asynchronously:[^1]

[^1]: Throughout this series, whenever it's unambiguous, I'll refer to `Result<Value, Error>` as just "Value."

```swift
// A transport maps a URLRequest to Data, asynchronously
protocol Transport {
    func send(request: URLRequest,
              completion: @escaping (Result<Data, Error>) -> Void)
}
```

Notice that nothing about that says "HTTP server over the network." Anything that can map a URLRequest to Data asynchronously is fine. It could be a database. It could be static unit test data. It could be flat files. It could be different routes depending on the scheme.

Now comes the power of retroactive modeling. I can extend URLSession to be a Transport:

```swift
extension URLSession: Transport {
    func send(request: URLRequest,
              completion: @escaping (Result<Data, Error>) -> Void)
    {
        self.dataTask(with: request) { (data, _, error) in
            if let error = error { completion(.failure(error)) }
            else if let data = data { completion(.success(data)) }
            }.resume()
    }
}
```

And then anything that requires a Transport can use a URLSession directly. No need for wrappers or adapters. It just works, even though URLSession is a Foundation type and Apple doesn't know anything about my Transport protocol. A few lines of code and it just works, without giving up any of the power of URLSession.

<style>
    .chl { color: yellow; } /* code highlight */
</style>

With that in place, `APIClient` can use Transport rather than URLSession.

<pre>
final class APIClient {
    let baseURL = URL(string: &quot;https://www.example.com&quot;)!

    <span class="chl">let transport: Transport</span>   

    <span class="chl">init(transport: Transport = URLSession.shared) {
        self.transport = transport
    }</span>

    // Fetch any Fetchable type given an ID, and return it asynchronously
    func fetch&lt;Model: Fetchable&gt;(_ model: Model.Type,
                                 id: Int,
                                 completion: @escaping (Result&lt;Model, Error&gt;) -&gt; Void)
    {
        // Construct the URLRequest
        let urlRequest = URLRequest(url: baseURL
            .appendingPathComponent(Model.apiBase)
            .appendingPathComponent(&quot;\(id)&quot;)
        )

        // Send it to the transport
        <span class="chl">transport.send(request: urlRequest) { data in
            completion(Result {
                return try JSONDecoder().decode(Model.self,
                                                from: data.get())
            })
        }</span>
    }
}
</pre>

By using a default value in `init`, callers can still use the `APIClient()` syntax if they want the standard network transport.

Transport is a lot more powerful than just "a URLSession mock." It's a function that converts URLRequests into Data. That means it can be composed. I can build a Transport that wraps other Transports. For example, I can build a Transport that adds headers to every request.

```swift
// Add headers to an existing transport
final class AddHeaders: Transport
{
    let base: Transport
    var headers: [String: String]

    init(base: Transport, headers: [String: String]) {
        self.base = base
        self.headers = headers
    }

    func send(request: URLRequest,
               completion: @escaping (Result<Data, Error>) -> Void)
    {
        var newRequest = request
        for (key, value) in headers { newRequest.addValue(value, forHTTPHeaderField: key) }
        base.send(request: newRequest, completion: completion)
    }
}

let transport = AddHeaders(base: URLSession.shared,
                           headers: ["Authorization": "..."])
```

Now, rather than having every request deal with authorization, that can be centralized to a single Transport transparently. If the authorization token changes, then I can update a single object, and all future requests will get the right headers. But this is still unit testable (even the AddHeaders part). I can swap in whatever lower-level Transport I want.

This means I can extend existing systems in a really flexible way. I can add encryption or logging or caching or priority queues or automatic retries or whatever without intermingling that with the actual network layer. I can tunnel all the network traffic over a custom VPN protocol (I've done exactly that with a system like this), all without losing the ability to unit test. So yes, I get mocks, yes, I get unit testing, but I get so much more.

For completeness, here's a "mock" Transport, but it's probably the least interesting thing we can do with this protocol.

```swift
// A transport that returns static values for tests
enum TestTransportError: Swift.Error { case tooManyRequests }

final class TestTransport: Transport {
    var history: [URLRequest] = []
    var responseData: [Data]

    init(responseData: [Data]) { self.responseData = responseData }

    func send(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        history.append(request)
        if !responseData.isEmpty {
            completion(.success(responseData.removeFirst()))
        } else {
            completion(.failure(TestTransportError.tooManyRequests))
        }
    }
}
```

And I still haven’t used an associated type or a Self requirement. Transport doesn't need any of that. It's not even generic.

## Common currency

The split between a `APIClient.fetch`, which is generic, and `Transport.send`, which is not, is a common structure that I look for. `Transport.send` operates on a small set of concrete types: URLRequest in, Data out. When you're working with a small set of concrete types, then composition is easy. Anything that can generate a URLRequest or can consume Data can participate. `APIClient.fetch` converts Data into any kind of generic Fetchable. When angle-brackets and associated types start creeping in, the code becomes more expressive, but harder to compose because you have to make sure all the types line up.

The power of the Internet is that it mostly operates on just one type: the packet. It doesn't care what's in the packet or what the packet "means." It just moves packets from one place to another; packets in, packets out. And that's why the Internet is so flexible, and the equipment that makes it work can be implemented by numerous vendors in wildly different ways, and they can all work together. 

At each layer above the network layer, additional context and meaning is applied to the information. It's interpreted as user information or commands to execute or video to display. That's composition, gluing together independent layers, each with their own concerns. When designing protocols, I try to employ the same approach. Particularly at the lowest layers I look for common, concrete types to work with. URL and URLRequest. Data and Int. Simple functions like `() -> Void`. As I move up the stack, then greater meaning is applied to the data in the form of model types and the like. That means it's easy to write Transports and many different things can use Transports. And that's the goal.

This network stack still is nowhere near as flexible and powerful as I want. But now it can fetch a wide variety of model types from a particular type of API in a very composable and testable way. That's great progress. For some very simple APIs, it might even be done. There's no need to make it more flexible for its own sake. But I think we'll quickly find more features we need to add.

Next time, I'll jump back up to the very top of the stack, to the models, and show where a PAT (protocol with associated type) can really shine.

[Swift Playground](/assets/protocols/StartWithAProtocol.zip)