// Code for Protocols II: A Mockery of Protocols
// http://robnapier.net/a-mockery-of-protocols

import Foundation

// Something that can be fetched from the API
protocol Fetchable: Decodable {
    static var apiBase: String { get }  // The part of the URL for this fetchable type
}

// A transport maps a URLRequest to Data, asynchronously
protocol Transport {
    func send(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void)
}

// Retroactively model URLSession as a Transport
extension URLSession: Transport {
    func send(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void)
    {
        let task = self.dataTask(with: request) { (data, _, error) in
            if let error = error { completion(.failure(error)) }
            else if let data = data { completion(.success(data)) }
        }
        task.resume()
    }
}

// A client that fetches things from the API
final class APIClient {
    let baseURL = URL(string: "https://www.example.com")!
    let transport: Transport

    init(transport: Transport = URLSession.shared) { self.transport = transport }

    // Fetch any Fetchable type given an ID, and return it asynchronously
    func fetch<Model: Fetchable>(_ model: Model.Type, id: Int,
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

// User model object
struct User: Codable, Hashable {
    let id: Int
    let name: String
}

// Document model object
struct Document: Codable, Hashable {
    let id: Int
    let title: String
}

extension User: Fetchable {
    static var apiBase: String { return "user" }
}

extension Document: Fetchable {
    static var apiBase: String { return "document" }
}

// Add headers to an existing transport
final class AddHeaders: Transport
{
    let base: Transport
    var headers: [String: String]

    init(base: Transport, headers: [String: String]) {
        self.base = base
        self.headers = headers
    }

    func send(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void)
    {
        var newRequest = request
        for (key, value) in headers { newRequest.addValue(value, forHTTPHeaderField: key) }
        base.send(request: newRequest, completion: completion)
    }
}

let transport = AddHeaders(base: URLSession.shared,
                           headers: ["Authorization": "..."])

APIClient(transport: transport).fetch(User.self, id: 1) {
    print($0)
}

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

let mock = TestTransport(responseData: [try! JSONEncoder().encode(User(id: 1, name: "alice"))])

let client = APIClient(transport: mock)
client.fetch(User.self, id: 1, completion: { print($0)} )   // Success
client.fetch(User.self, id: 1, completion: { print($0)} )   // Failure
