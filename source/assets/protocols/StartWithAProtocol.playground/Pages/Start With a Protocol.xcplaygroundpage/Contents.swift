// Code for Protocols I: "Start with a protocol," he said
// http://robnapier.net/start-with-a-protocol

import Foundation

// Something that can be fetched from the API
protocol Fetchable: Decodable {
    static var apiBase: String { get }
}

// A client that fetches things from the API
final class APIClient {
    let baseURL = URL(string: "https://www.example.com")!
    let session: URLSession = URLSession.shared

    func fetch<Model: Fetchable>(_ model: Model.Type,
                                 id: Int,
                                 completion:
        @escaping (Result<Model, Error>) -> Void)
    {
        let urlRequest = URLRequest(url: baseURL
            .appendingPathComponent(Model.apiBase)
            .appendingPathComponent("\(id)")
        )

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

APIClient().fetch(User.self, id: 1) {
    print($0)
}
