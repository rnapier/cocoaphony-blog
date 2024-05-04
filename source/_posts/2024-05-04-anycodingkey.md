---
layout: post
title: AnyCodingKey
date: 2024-05-04 16:37 -0400
---
Let’s talk about CodingKey. It’s a protocol. It is not a magic enum thing. Coding keys do not have to be enums. There is some special compiler magic for when CodingKeys are enums, but it’s just a protocol.

It’s something that wraps a string value, that may also wrap an int value. That’s it.

```swift
public protocol CodingKey : CustomDebugStringConvertible, CustomStringConvertible, Sendable {
    var stringValue: String { get }
    init?(stringValue: String)
    var intValue: Int? { get }
    init?(intValue: Int)
}
```
<!-- more -->

You can see how the compiler generates automatic coding keys by running it through `swiftc -print-ast`. That will output the Abstract Syntax Tree as Swift code, after automatic conformances are injected.

```sh
% echo 'struct Person:Decodable { var name: String }' | swiftc -print-ast -
```

```swift
// Output of `-print-ast`
internal struct Person : Decodable {
  internal var name: String
  private enum CodingKeys : CodingKey {
    case name
    @_implements(Equatable, ==(_:_:)) fileprivate static func __derived_enum_equals(_ a: Person.CodingKeys, _ b: Person.CodingKeys) -> Bool {
      private var index_a: Int
      switch a {
      case .name:
        index_a = 0
      }
      private var index_b: Int
      switch b {
      case .name:
        index_b = 0
      }
      return index_a == index_b
    }
    fileprivate func hash(into hasher: inout Hasher) { ... }
    ...
}
```

It’ll generate an enum, and a few dozen or a few hundred lines worth of conformances. You’ll notice that Equatable implementation is based on a switch statement and numeric values rather than the string comparison you might have expected. Comparing integers is a lot faster than strings.

But the important part is that it generates a very simple `stringValue` initializer and property. For int values, it just returns nil. It doesn’t support int values.

```swift
private init?(stringValue: String) {
  switch stringValue {
  case "name":
    self = Person.CodingKeys.name
  default:
    return nil
  }
}

private init?(intValue: Int) {
  return nil
}

fileprivate var intValue: Int? {
  get { return nil }
}

fileprivate var stringValue: String {
  get {
    switch self {
    case .name:
      return "name"
    }
  }
}
```

What if we made a struct that did the same thing? Glad you asked:

```swift
public struct AnyCodingKey: CodingKey {
    public let stringValue: String

    public var intValue: Int?

    public init(stringValue: String) {
        self.stringValue = stringValue
    }

    public init?(intValue: Int) { return nil }
}
```

This is my absolute favorite custom type and I use it all the time. This is its most minimal form, and the way you’ll see it pretty often in the wild. Lots of people have invented this under different names.

The form I use is a [little more fancy](https://github.com/rnapier/advanced-codable/blob/26a4b09c7647b169289512aa877f7e118b6442cc/Codable.playground/Pages/Defaulting.xcplaygroundpage/Contents.swift#L19-L35). It supports Int keys, and most importantly it conforms to ExpressibleByStringLiteral so that I can use quoted strings as keys. But at its heart, it’s just this, a coding key that can wrap any String and so can be the key of any JSON object.

Why do I love this struct so much? Well, for one, it gets rid of the need for defining CodingKeys. 

```swift
struct Person: Decodable {
    var name: String
    var age: Int
    var children: [Person]?
}

init(from decoder: Decoder) throws {
    let c = try decoder.container(keyedBy: AnyCodingKey.self)

    name     = try c.decode(String.self, forKey: "name")
    age      = try c.decode(Int.self, forKey: "age")
    children = try c.decodeIfPresent([Person].self, forKey: "children")
}
```

The hard-coded string literals may cause you to freak out a little. But here’s the thing. If you’re only implementing Decodable or only implementing Encodable, that string will occur in exactly one place which is exactly the place you use it. That’s better than creating a hand-written constant somewhere else. And I generally recommend that you only implement Encodable or Decodable unless you need them both. Unneeded conformances just add headaches and overhead.

And with this tool some really interesting, and ultimately quite simple, syntax is possible.

```swift
extension Decoder {
    public func anyKeyedContainer() throws -> KeyedDecodingContainer<AnyCodingKey> {
        try container(keyedBy: AnyCodingKey.self)
    }
}

extension KeyedDecodingContainer {
    public subscript<T: Decodable>(key: Key) -> T {
        get throws { try self.decode(T.self, forKey: key) }
    }
    public subscript<T: Decodable>(ifPresent key: Key) -> T? {
        get throws { try self.decodeIfPresent(T.self, forKey: key) }
    }
}
```

And now, custom decoding looks like this:

```swift
init(from decoder: Decoder) throws {
    let c = try decoder.anyKeyedContainer()
    name     = try c["name"]
    age      = try c["age"]
    children = try c[ifPresent: "children"]
}
```

See my [advanced-codable](https://github.com/rnapier/advanced-codable/blob/main/Codable.playground/Sources/Decoder%2BAnyCodingKey.swift) repo for lots of examples that handle optionals, default values, robust error handling, and more. But the point isn't to build a fancy library. The point is that with just a few lines of code, you can implement the things you need for your specific problem. And that the starting point is AnyCodingKey.