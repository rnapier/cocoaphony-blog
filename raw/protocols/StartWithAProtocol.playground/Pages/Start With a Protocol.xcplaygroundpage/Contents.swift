// Code for Protocols I: "Start with a protocol," he said
// http://robnapier.net/start-with-a-protocol

import Foundation

// Something that can be fetched from the API
protocol Fetchable: Decodable {
    static var apiBase: String { get } // The part of the URL for this type
}

// A client that fetches things from the API
final class APIClient {
    let baseURL = URL(string: "https://www.example.com")!
    let session: URLSession = URLSession.shared

    // Fetch any Fetchable type given an ID, and return it asynchronously
    func fetch<Model>(_ model: Model.Type, id: Int,
                      completion: @escaping (Result<Model, Error>) -> Void)
        where Model: Fetchable
    {
        // Construct the URLRequest
        let url = baseURL
            .appendingPathComponent(Model.apiBase)
            .appendingPathComponent("\(id)")
        let urlRequest = URLRequest(url: url)

        // Send it to URLSession
        let task = session.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                let result = Result { try JSONDecoder().decode(Model.self, from: data) }
                completion(result)
            }
        }
        task.resume()
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
