import Foundation

struct User: Codable, Hashable {
    let id: Int
    let name: String
}

struct Document: Codable, Hashable {
    let id: Int
    let title: String
}

final class APIClient {
    let baseURL = URL(string: "https://www.example.com")!
    let session = URLSession.shared

    func fetchUser(id: Int,
                   completion:
        @escaping (Result<User, Error>) -> Void)
    {
        let urlRequest = URLRequest(url: baseURL
            .appendingPathComponent("user")
            .appendingPathComponent("\(id)")
        )

        session.dataTask(with: urlRequest) { (data, _, error) in
            if let error = error { completion(.failure(error)) }
            else if let data = data {
                completion(Result {
                    try JSONDecoder().decode(User.self, from: data)
                })
            }
            }.resume()
    }
}
