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
