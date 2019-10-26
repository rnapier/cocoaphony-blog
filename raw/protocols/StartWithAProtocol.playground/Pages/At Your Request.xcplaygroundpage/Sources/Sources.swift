import Foundation

// A transport maps a URLRequest to Data, asynchronously
public protocol Transport {
    func send(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void)
}

// Retroactively model URLSession as a Transport
extension URLSession: Transport {
    public func send(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void)
    {
        let task = self.dataTask(with: request) { (data, _, error) in
            if let error = error { completion(.failure(error)) }
            else if let data = data { completion(.success(data)) }
        }
        task.resume()
    }
}

public enum TestTransportError: Swift.Error { case tooManyRequests }

public final class TestTransport: Transport {
    public var history: [URLRequest] = []
    public var responseData: [Data]

    public init(responseData: [Data]) { self.responseData = responseData }

    public func send(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        history.append(request)
        if !responseData.isEmpty {
            completion(.success(responseData.removeFirst()))
        } else {
            completion(.failure(TestTransportError.tooManyRequests))
        }
    }
}

// An identifier (of some Value type) that applies to a specific Model type
public struct Identifier<Model, Value> where Value: Codable & Hashable {
    public let value: Value
    public init(_ value: Value) { self.value = value }
}

extension Identifier: Codable, Hashable {
    public init(from decoder: Decoder) throws {
        self.init(try decoder.singleValueContainer().decode(Value.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

// Something identified with an Identifier
public protocol Identified: Codable {
    associatedtype IDType: Codable & Hashable
    typealias ID = Identifier<Self, IDType>
    var id: ID { get }
}

// User model object
public struct User: Identified {
    public typealias IDType = Int
    public let id: ID
    public let name: String
    public init(id: ID, name: String) {
        self.id = id
        self.name = name
    }
}

// Document model object
public struct Document: Identified {
    public typealias ID = Identifier<Document, String>
    public let id: ID
    public let title: String
    public init(id: ID, title: String) {
        self.id = id
        self.title = title
    }
}

public protocol Fetchable: Identified {
    static var apiBase: String { get }  // The part of the URL for this fetchable type
}

extension User: Fetchable {
    public static var apiBase: String { return "user" }
}

extension Document: Fetchable {
    public static var apiBase: String { return "document" }
}
