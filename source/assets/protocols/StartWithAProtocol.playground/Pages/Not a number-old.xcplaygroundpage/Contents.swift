// Code for Protocols II: A Mockery of Protocols
// http://robnapier.net/a-mockery-of-protocols

import Foundation

// Something that can be fetched from the API
protocol Fetchable: Decodable {
    associatedtype ID: IDType
    static var apiBase: String { get }  // The part of the URL for this fetchable type
}

protocol IDType: Codable, Hashable {
    associatedtype Value: Codable, Hashable
    var value: Value { get }
    init(value: Value)
}

extension IDType {
    init(_ value: Value) { self.init(value: value) }
}

// A client that fetches things from the API
final class APIClient {
    let baseURL = URL(string: "https://www.example.com")!
    let transport: Transport

    init(transport: Transport = URLSession.shared) { self.transport = transport }

    // Fetch any Fetchable type given an ID, and return it asynchronously
    func fetch<Model: Fetchable>(_ model: Model.Type, id: Model.ID,
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
    struct ID: IDType { let value: Int }
    let id: ID
    let name: String
}

// Document model object
struct Document: Codable, Hashable {
    struct ID: IDType { let value: String }
    let id: ID
    let title: String
}

extension User: Fetchable {
    static var apiBase: String { return "user" }
}

extension Document: Fetchable {
    static var apiBase: String { return "document" }
}

let mock = TestTransport(responseData: [try! JSONEncoder().encode(User(id: User.ID(1), name: "alice"))])

let client = APIClient(transport: mock)
client.fetch(User.self, id: User.ID(1), completion: { print($0)} )   // Success
