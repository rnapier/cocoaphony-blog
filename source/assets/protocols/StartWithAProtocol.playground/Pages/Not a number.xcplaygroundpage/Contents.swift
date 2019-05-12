// Code for Protocols III: That's not a number
// http://robnapier.net/thats-not-a-number

import Foundation

protocol IDType: Codable, Hashable {
    associatedtype Value: Codable, Hashable
    var value: Value { get }
    init(value: Value)
}

extension IDType {
    init(_ value: Value) { self.init(value: value) }
}

// User model object
struct User: Codable, Hashable {
    struct ID: IDType { let value: Int }
    let id: ID
    let name: String
}

let user = User(id: User.ID(1), name: "Alice")

// Document model object
struct Document: Codable, Hashable {
    struct ID: IDType { let value: String }
    let id: ID
    let title: String
}
