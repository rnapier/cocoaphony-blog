// Code for Protocols III: That's not a number
// http://robnapier.net/thats-not-a-number

import Foundation

protocol Identifier: Codable, Hashable {
    associatedtype Value: Codable, Hashable
    var value: Value { get }
    init(value: Value)
}

extension Identifier {
    init(_ value: Value) { self.init(value: value) }
}

// User model object
struct User: Codable, Hashable {
    struct ID: Identifier { let value: Int }
    let id: ID
    let name: String
}

let user = User(id: User.ID(1), name: "Alice")

// Document model object
struct Document: Codable, Hashable {
    struct ID: Identifier { let value: String }
    let id: ID
    let title: String
}

protocol Fetchable: Decodable {
    associatedtype ID: Identifier
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

let alice = User(id: User.ID(1), name: "alice")
let mock = TestTransport(responseData: [try! JSONEncoder().encode(alice)])

let client = APIClient(transport: mock)
client.fetch(User.self, id: User.ID(1), completion: { print($0)} )   // Success
client.fetch(User.self, id: User.ID(1), completion: { print($0)} )   // Failure

var users: [User.ID: User] = [:]
var documents: [Document.ID: Document] = [:]

let userID = User.ID(1)
let documentID = Document.ID("password")

struct Action {
    let perform: () -> Void
}

let userRequest = Action {
    client.fetch(User.self, id: userID) {
        switch $0 {
        case .success(let model): users[userID] = model
        case .failure(let error): print("Failure fetching \(userID): \(error)")
        }
    }
}

struct RefreshRequest {
    let perform: () -> Void

    static func logError<ID: Identifier>(id: ID, error: Error) {
        print("Failure fetching \(id): \(error)")
    }

    init<Model: Fetchable>(id: Model.ID,
                           with client: APIClient = APIClient.shared,
                           completion: @escaping (Result<Model, Error>) -> Void)
    {
        perform = {
            client.fetch(Model.self, id: id, completion: completion)
        }
    }

    init<Model: Fetchable>(id: Model.ID,
                           with client: APIClient = APIClient.shared,
                           updateHandler: @escaping (Model) -> Void,
                           errorHandler: @escaping (Model.ID, Error) -> Void = logError)
    {
        self.init(id: id, with: client) { (result: Result<Model, Error>) in
            switch result {
            case .success(let model): updateHandler(model)
            case .failure(let error): errorHandler(id, error)
            }
        }
    }
}

let requests = [
    RefreshRequest(id: userID, updateHandler: { users[$0.id] = $0 }),
    RefreshRequest(id: documentID, updateHandler: { documents[$0.id] = $0 }),
]

