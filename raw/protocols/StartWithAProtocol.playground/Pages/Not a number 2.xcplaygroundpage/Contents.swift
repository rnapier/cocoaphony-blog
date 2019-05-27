// Code for Protocols III: That's not a number
// http://robnapier.net/thats-not-a-number

import Foundation

struct Identifier<Model, Value>: Codable, Hashable
where Value: Codable & Hashable {
    let value: Value
    init(_ value: Value) { self.value = value }
}

// Something identified with an Identifier
protocol Identified {
    associatedtype IDType: Codable & Hashable
    typealias ID = Identifier<Self, IDType>
    var id: ID { get }
}

protocol ModelType: Identified, Codable, Hashable {}

// User model object
struct User: ModelType {
    typealias IDType = Int
    let id: ID
    let name: String
}

let user = User(id: User.ID(1), name: "Alice")

// Document model object
struct Document: ModelType {
    typealias ID = Identifier<Document, String>
    let id: ID
    let title: String
}

protocol Fetchable: Identified {
    static var apiBase: String { get }  // The part of the URL for this fetchable type
}

extension User: Fetchable {
    static var apiBase: String { return "user" }
}

extension Document: Fetchable {
    static var apiBase: String { return "document" }
}

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

let alice = User(id: User.ID(1), name: "alice")
let mock = TestTransport(responseData: [try! JSONEncoder().encode(alice)])

let client = APIClient(transport: mock)
client.fetch(User.ID(1), completion: { print($0)} )   // Success
client.fetch(User.ID(1), completion: { print($0)} )   // Failure

var users: [User.ID: User] = [:]
var documents: [Document.ID: Document] = [:]

let userID = User.ID(1)
let documentID = Document.ID("password")
