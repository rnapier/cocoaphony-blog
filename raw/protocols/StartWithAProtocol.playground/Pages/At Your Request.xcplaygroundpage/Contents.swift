// Code for Protocols V: At Your Request
// http://robnapier.net/at-your-request

import Foundation

struct Request {
    let urlRequest: URLRequest
    let completion: (Result<Data, Error>) -> Void
}

extension Request {
    static var baseURL: URL { URL(string: "https://www.example.com")! }

    // GET /<model>/<id> -> Model
    static func fetching<Model: Fetchable>(
        id: Model.ID,
        completion: @escaping (Result<Model, Error>) -> Void)
        -> Request
    {
        let urlRequest = URLRequest(url: Self.baseURL
            .appendingPathComponent(Model.apiBase)
            .appendingPathComponent("\(id)")
        )

        return self.init(urlRequest: urlRequest) {
            data in
            completion(Result {
                let decoder = JSONDecoder()
                return try decoder.decode(Model.self, from: data.get())
            })
        }
    }
}

extension Request {
    // POST /keepalive -> Error?
    static func keepAlive(
        completion: @escaping (Error?) -> Void) -> Request
    {
        var urlRequest = URLRequest(url: baseURL
            .appendingPathComponent("keepalive")
        )
        urlRequest.httpMethod = "POST"

        return self.init(urlRequest: urlRequest) {
            switch $0 {
            case .success: completion(nil)
            case .failure(let error):
                completion(error)
            }
        }
    }
}

final class APIClient {
    static let shared = APIClient()
    let transport: Transport

    init(transport: Transport = URLSession.shared) { self.transport = transport }

    func send(_ request: Request) {
        transport.send(request: request.urlRequest,
                        completion: request.completion)
    }
}

let alice = User(id: User.ID(1), name: "alice")
let mock = TestTransport(responseData: [try! JSONEncoder().encode(alice)])

let client = APIClient(transport: mock)
client.send(Request.fetching(id: User.ID(1), completion: { print($0)} ))   // Success
client.send(Request.fetching(id: User.ID(1), completion: { print($0)} ))   // Failure

var users: [User.ID: User] = [:]
var documents: [Document.ID: Document] = [:]

let userID = User.ID(1)
let documentID = Document.ID("password")
