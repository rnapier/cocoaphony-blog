---
layout: post
title: "A Mockery of Types"
published: true
categories: testing
---

I'm going to talk about testing over the next few posts. If you've talked to me at any length over the last several years, you know I've been thinking about testing a lot over the years, and I have somewhat unorthodox opinions. Unorthodox enough that I really haven't wanted to write them down because I'm really not trying to start an argument with anyone. If your approach to testing works for you and your team, I think you're doing it right and I don't think you should change just because I do it a different way.

But if you and your team struggle with testing and you think it's because you lack the discipline to "do things right," I'd like to offer another way of thinking about testing that has worked very well for many years, for several teams, and in multiple languages. In this series I'm going to focus specifically on iOS development working in Swift. Some topics are different in other environments. I might touch on those eventually, but to keep this already sprawling topic bounded, I'm going to stick to client-side Swift for now.

So none of this may apply to you. But if you feel that your current testing approach isn't working, I'd like to offer another option:

*Mock as little as you can. Mock only at the edges. Minimize dependency injection. Test real code.*

<!-- more -->

This is the point in the conversation at which many a good and wise friend has, with great kindness, called me an idiot. And before I'm done, you might too. And that's fine. If your fancy DI framework is working for you, you shouldn't abandon it. Maybe listen to some of my philosophical points and ignore the rest. Or ignore it all. I'm warning you up front where this is headed.

But the best thing I've done for testing in multiple code bases has been to delete nearly all the mocks and mostly remove dependency injection. In the process, I've also made production code better. I've spent the last few months removing mocks from my current project while also improving test code coverage by tens of thousands of lines. Tests are simpler to write and they actually test real things. It's possible to do a lot of testing with very little mocking.

I want to start this series with a concrete example: [a Keychain wrapper](/assets/testing/Stage1/Keychain.swift). We've all used them. I've worked with many on several teams (and sometimes several on the same team), and this example is based on lessons learned from all of them.

{% pullquote %}
You're going to look at this wrapper and think "that's not an ideal design," and you're right. But it's the kind of design you'll find in real code bases. {" We need to be able to test things that aren't perfect. "} You don't need to read it all now. The comments at the top are enough, and I'll explain the whole API along the way.
{% endpullquote %}

```swift
/// A Keychain wrapper that offers key/value storage with the following features:
///
/// * Takes an identifier to maintain separate stores
/// * Each Keychain offers independent key/value storage
/// * Caches values in memory for performance
/// * Allows reading and writing Data directly
/// * Encodes Strings as UTF-8
/// * Encodes JSONSerialization-compatible types (except String and Data) as JSON
/// * Supports "reset" to delete all keys for this identifier
///
public actor Keychain {
  public let identifier: String
  private var cache: [String: Data] = [:]

  public init(identifier: String) { self.identifier = identifier }

  // MARK: - Data Operations

  public func data(for key: String) throws -> Data? {
    // First check the cache
    if let data = cache[key] {
      return data
    }

    // That terrible `SecItemCopyMatching` call you all know...
    let data = try _data(for: key)

    // And cache it for later
    cache[key] = data
    return data
  }

  public func set(data: Data, for key: String) throws {
    // Set it to the cache and to system keychain
    cache[key] = data
    try _set(data: data, for: key)
  }

  public func removeData(for key: String) throws {
    // Remove it from the cache and to system keychain
    cache[key] = nil
    try _removeData(for: key)
  }

  // Clear the cache and delete all keys for this identifier
  public func reset() throws {
    cache = [:]
    try _reset()
  }

  // MARK: - String Operations -- Encode as UTF-8

  public func string(for key: String) throws -> String? {
    guard let data = try data(for: key) else { return nil }
    return String(data: data, encoding: .utf8)
  }

  public func set(string: String, for key: String) throws {
    try set(data: Data(string.utf8), for: key)
  }

  // MARK: - JSONSerialization Operations

  public func value(for key: String) throws -> Any? {
    guard let data = try data(for: key) else { return nil }
    return try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
  }

  public func set(value: Any, for key: String) throws {
    let data = try JSONSerialization.data(withJSONObject: value, options: [.fragmentsAllowed])
    try set(data: data, for: key)
  }

  // MARK: - Public Extensions for Common Types (Bool, Int)

  public func bool(for key: String) throws -> Bool? { try value(for: key) as? Bool }
  public func set(bool: Bool, for key: String) throws { try set(value: bool, for: key) }

  public func int(for key: String) throws -> Int? { try value(for: key) as? Int }
  public func set(int: Int, for key: String) throws { try set(value: int, for: key) }

  // MARK: - All those horrible low-level SecItem... wrappers that I'm not going to bore you with

  private func _data(for key: String) throws -> Data? { 
    // ...
  }
  private func _set(data: Data, for key: String) throws {
    // ...
  }
  private func _removeData(for key: String) throws {
    // ...
  }
  private func _reset() throws {
    // ...
  }
}
```
{: .scroll}

Some key points to this code that will come up later:

* Calling `set(string:forKey:)` encodes the value differently than `set(value:forKey:)` when passing a `String`. In some cases, a mismatch will lead to returning the wrong value (quoted vs not-quoted). In other cases it may return `nil`. "Well that's awkward, let's fix it!" But remember, this code has shipped. Millions of keys have already been written to user keychains. If you change how it's encoded, you need to write a migrator. There may be other code that has hacked around the current behavior and will break if you change it (ask me why I think that might happen…). Before you go redesigning a critical piece of persistent storage, it sure would be nice to have tests, right? As much as we can, we want a system that can deal with things as they are, not just how they should be.[^why]

[^why]: "Why would anyone build it this way?!?!?" While I've invented this version for this article, it's based on many similar ones I've worked with and it's very natural to get here. The `Data` and `String` interfaces are built first and are all anyone needs at the time. Later, the `Any` interface is added to deal with `[String: Any]` dictionaries from the legacy networking stack. It happens to work fine for things like `Int` and `Bool`, so people start to use the `Any` interface for those, and then convenience methods are added. Then someone wants `Codable` support, but is afraid to modify the widely used `Keychain`, and so adds it locally in a module. Someone else does the same in another module, but instead of `JSONEncoder`, uses `PropertyListEncoder`. So now if you try to merge all the different interfaces, you'll find they're incompatible. [Yagni](https://martinfowler.com/bliki/Yagni.html) tells us not to build features we don't need yet. We only need `Data` and `String`, and then `[String: Any]`, and then just one module needs `Codable`, and then… Unifying at any point would introduce risky data migration for thousands of users that no project wants to add to their schedule. And that, my friends, is a downside of yagni that doesn't get enough discussion. But that's another blog post.

* This code cannot be called as-is from a unit test on any platform but macOS if the test lives in an SPM package (rather than a hosted application). To access the system keychain, even on Simulator, requires an entitlements file, and SPM can't provide it. That means that some kind of "mocking" solution is absolutely required for any non-macOS SPM code that relies on `Keychain`. It's literally impossible to test otherwise. The point of this article and series isn't "never mock." It's to reduce mocking as much as we can.

{% pullquote %}
For the moment, I want to ignore how we test this module itself. Maybe it's been around for years and you've never had any bugs from it. Should you even write tests at that point? Meh? {" We do not write tests for virtue's sake. "} They are work, and we need to have a reason to write them. In a later post I'll discuss the many different reasons to write tests, but chasing ever-higher code coverage targets isn't one of them.
{% endpullquote %}

I want to talk about things that we want to test that *use* `Keychain`. Since using `Keychain` completely breaks unit tests for iOS, we need to do something.

So, I'm going to reach for the tool you're all thinking of. It's the wrong tool, but it's [where we all start](/start-with-a-protocol). I'm going to make a protocol!

## Abusing Protocols for Tests and (Dubious) Profit

Here we go. Each public method becomes a protocol requirement:

```swift
public protocol KeychainProtocol: Actor {
  func data(for key: String) throws -> Data?
  func set(data: Data, for key: String) throws
  func removeData(for key: String) throws
  func reset() throws

  func string(for key: String) throws -> String?
  func set(string: String, for key: String) throws

  func value(for key: String) throws -> Any?
  func set(value: Any, for key: String) throws

  func bool(for key: String) throws -> Bool?
  func set(bool: Bool, for key: String) throws

  func int(for key: String) throws -> Int?
  func set(int: Int, for key: String) throws
}
```
And we build a mock. Because we always need a mock:

```swift
public actor MockKeychain: KeychainProtocol {
  private var storage: [String: Data] = [:]

  //
  // Data accessors
  //
  public func data(for key: String) throws -> Data? { storage[key] }
  public func set(data: Data, for key: String) throws { storage[key] = data }
  public func removeData(for key: String) throws { storage[key] = nil }
  public func reset() throws { storage.removeAll() }

  //
  // Codable accessors
  //
  public func string(for key: String) throws -> String? { try decode(key: key) }
  public func set(string: String, for key: String) throws { try store(string, for: key)}
  public func bool(for key: String) throws -> Bool? { try decode(key: key) }
  public func set(bool: Bool, for key: String) throws { try store(bool, for: key) }
  public func int(for key: String) throws -> Int? { try decode(key: key) }
  public func set(int: Int, for key: String) throws { try store(int, for: key) }

  //
  // JSONSerialization accessors
  //
  public func value(for key: String) throws -> Any? {
    guard let data = storage[key] else { return nil }
    return try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
  }

  public func set(value: Any, for key: String) throws {
    storage[key] = try JSONSerialization.data(withJSONObject: data, options: [.fragmentsAllowed])
  }

  //
  // Private helpers
  //
  private func decode<T: Codable>(key: String, as: T.Type = T.self) throws -> T? {
    guard let data = storage[key] else { return nil }
    return try JSONDecoder().decode(T.self, from: data)
  }

  private func store<T: Codable>(_ value: T, for key: String) throws {
    storage[key] = try JSONEncoder().encode(value)
  }
}
```

## Make your mocks small

This is exactly how I've seen this problem solved so many times. And now that I've written it out myself, I must cry a little. Give me a moment. Please… stop doing this. You can have your mocks. Mock if it makes you happy. But stop doing this. There's no need to even mock this type, which I'll get to in a little bit, but if you're going to mock it with a protocol, this is how to do it:

```swift
public protocol KeychainProtocol: Actor {
  func data(for key: String) throws -> Data?
  func set(data: Data, for key: String) throws
  func removeData(for key: String) throws
  func reset() throws
}
```

I don't like to end protocols with `...Protocol`, but I'm going to leave that for now. The point is that the protocol only covers the things that actually need mocking, which is the part that reads and writes storage. The vast majority of `Keychain` has nothing to do with the system keychain. Most of the methods implement encoding logic, "business" logic. There is nothing about encoding logic that needs mocking. So it shouldn't be mocked. You want to test it! Instead, that logic should be moved to a protocol extension.

```swift
extension KeychainProtocol {
  // MARK: - String Operations

  public func string(for key: String) throws -> String? {
    guard let data = try data(for: key) else { return nil }
    return String(data: data, encoding: .utf8)
  }

  public func set(string: String, for key: String) throws {
    try set(data: Data(string.utf8), for: key)
  }

  // MARK: - JSON Value Operations

  public func value(for key: String) throws -> Any? {
    guard let data = try data(for: key) else { return nil }
    return try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
  }

  public func set(value: Any, for key: String) throws {
    let data = try JSONSerialization.data(withJSONObject: value, options: [.fragmentsAllowed])
    try set(data: data, for: key)
  }

  // MARK: - Public Extensions for Common Types (Bool, Int)

  public func bool(for key: String) throws -> Bool? { try value(for: key) as? Bool }
  public func set(bool: Bool, for key: String) throws { try set(value: bool, for: key) }

  public func int(for key: String) throws -> Int? { try value(for: key) as? Int }
  public func set(int: Int, for key: String) throws { try set(value: int, for: key) }
}
```
{: .scroll}

Now the entire mock looks like this:

```swift
public actor MockKeychain: KeychainProtocol {
  private var cache: [String: Data] = [:]

  public func data(for key: String) throws -> Data? { cache[key] }
  public func set(data: Data, for key: String) throws { cache[key] = data }
  public func removeData(for key: String) throws { cache[key] = nil }
  public func reset() throws { cache.removeAll() }
}
```

Mocks that fully duplicate their subject's API do it one of two ways:

* They copy a lot of the code from the subject.
* They *don't* copy a lot of the code from the subject.

Above is an example where I didn't copy a lot of code from the subject. I used `JSONEncoder` for everything rather than having custom logic for `String`. Since it's symmetrical, it "works," but the mock has diverged from the thing it's pretending to be. Consider this code:

```swift
@Test func testCrossStorage() async throws {
  // Write it as String
  try await keychain.set(string: "abc", for: "key")

  // Read it as data and decode manually
  let data = try #require(try await keychain.data(for: "key"))
  let result = String(decoding: data, as: UTF8.self)

  #expect(result == "abc")  // testCrossStorage(): Expectation failed: (result → ""abc"") == "abc"
}
```
This test works with the real `Keychain`, but it fails with the original mock that uses `Codable` internally. Nothing here is invalid. It's a weird way to use the system, but it's legal and even useful. If the caller wants the value as `Data` in order to write it to a file, there's no reason to round-trip it through `String`. They may rely on the fact that they know how it's encoded.

That's bad, but the test will fail, so at least it would be caught. The real problem is the reverse. Someone designs their system based on the mock's behavior rather than what you ship. All the tests will pass, but it will fail in the field. That's the worst case. You spend all this time building mocks, writing tests, running tests, and what do you get for all that? A bug that's a real pain to figure out because your tests are lying to you.

Of course, instead of re-implementing everything for the mock, I could have copied a lot more code from `Keychain` into `MockKeychain`, but that's not any better. It means that today they're aligned, but as `Keychain` evolves the two will almost certainly diverge. If the tests don't verify all visible behaviors (and that takes a lot more than just "100% code coverage"), then you'll have the same situation.

Instead, I made the mock protocol small. Just 4 methods:

```swift
public protocol KeychainProtocol: Actor {
  func data(for key: String) throws -> Data?
  func set(data: Data, for key: String) throws
  func removeData(for key: String) throws
  func reset() throws
}
```

Get, set, delete, reset. Those are what the rest of the code needs to operate. Those are exactly the methods I pulled out into some private helpers because they're kind of ugly.

## No, smaller than that

But what if we pulled them into a separate type like? What if instead of `KeychainProtocol`, it were `KeychainStorage` and `Keychain` HAS-A storage rather than IS-A storage?

So the storage is just a struct:

```swift
struct KeychainStorage {
  let identifier: String

  init(identifier: String) { self.identifier = identifier}

  // MARK: - All those horrible low-level SecItem... wrappers that I'm not going to bore you with

  private func data(for key: String) throws -> Data? { 
    // ...
  }
  private func set(data: Data, for key: String) throws {
    // ...
  }
  private func removeData(for key: String) throws {
    // ...
  }
  private func reset() throws {
    // ...
  }
}
```

And the `Keychain` uses it.

```swift
public actor Keychain {
  private var cache: [String: Data] = [:]
  private let storage: KeychainStorage?

  public init(identifier: String) {
    self.storage = KeychainStorage(identifier: identifier)
  }

  // MARK: - Data Operations

  public func data(for key: String) throws -> Data? {
    if let data = cache[key] {
      return data
    }

    let data = try storage?.data(for: key)
    cache[key] = data
    return data
  }

  public func set(data: Data, for key: String) throws {
    cache[key] = data
    try storage?.set(data: data, for: key)
  }

  public func removeData(for key: String) throws {
    cache[key] = nil
    try storage?.removeData(for: key)
  }

  public func reset() throws {
    cache = [:]
    try storage?.reset()
  }

  // ...
}
```

Wait, where did the protocol go? What about mocking? Look closely:

```swift
private let storage: KeychainStorage?
```

The storage is optional. What happens in this code if it's nil? Well, it reads and writes to a local dictionary, and doesn't do anything with the system keychain. Isn't that exactly what `KeychainMock` does?

`Keychain` is its own mock! All you need to do is set `storage = nil`. And if you modify `Keychain`, its mock automatically matches it because it's the same thing. The only thing we've removed is the little bit that we didn't want during testing: writing to the real keychain.

This is a shockingly powerful pattern. I call it "self-mocking" and I use it a lot. A whole lot. `Keychain` is possibly the most perfect example of it, but many types can benefit from this approach.

We just need a way to pass `nil` to `KeychainStorage.init`. Currently there's no way to do that, because how to do it right is a little subtle. That deserves its own post. Stay tuned.
