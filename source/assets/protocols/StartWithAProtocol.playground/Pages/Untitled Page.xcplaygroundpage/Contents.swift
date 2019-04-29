import Foundation

protocol Fetchable: Decodable {
    static var apiBase: String { get }
}

final class APIClient {
    let session: URLSession = URLSession.shared
    let baseURL = URL(string: "https://www.example.com")!

    func fetch<Model: Fetchable>(id: Int,
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

struct User: Codable, Hashable {
    let id: Int
    let name: String
}

extension User: Fetchable {
    static var apiBase: String { return "user" }
}

func dothing(user: Result<User, Error>) {}

APIClient().fetch(id: 2) { user in dothing(user: user) }
