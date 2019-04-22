import Foundation

protocol Request {
    associatedtype Response
    func parse(data: Data) throws -> Response
    var urlRequest: URLRequest { get }
}

let baseURL = URL(string: "http://example.com")!

struct User : Codable {
    let id: Int
    let name: String
}

struct UserRequest : Request {
    init(id: Int) {
        let url = baseURL.appendingPathComponent("users").appendingPathComponent("\(id)")
        urlRequest = URLRequest(url: url)
    }

    func parse(data: Data) throws -> User {
        return try JSONDecoder().decode(User.self, from: data)
    }

    var urlRequest: URLRequest
}
