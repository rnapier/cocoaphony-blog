import Foundation

/// A Keychain wrapper that offers key/value storage with the following features:
///
/// * Takes an identifier to maintain separate stores
/// * Each Keychain offers independent key/value storage
/// * Caches values in memory
/// * Allows reading and writing Data directly
/// * Encodes Strings as UTF-8
/// * Encodes JSONSerialization-compatible types in JSON
/// * Supports "reset" to delete all keys in this Keychain
///
public actor Keychain {
  public let identifier: String
  private var cache: [String: Data] = [:]

  public init(identifier: String) {
    self.identifier = identifier
  }

  // MARK: - Data Operations

  public func data(for key: String) throws -> Data? {
    if let data = cache[key] {
      return data
    }

    var params = makeParameters(for: key)
    params[kSecMatchLimit] = kSecMatchLimitOne
    params[kSecReturnData] = kCFBooleanTrue
    var result: CFTypeRef?
    let status = SecItemCopyMatching(
      params as CFDictionary,
      &result)

    if status == errSecItemNotFound {
      return nil
    }

    guard status == errSecSuccess else {
      throw Error.keychain(status)
    }

    let data = result as? Data
    cache[key] = data
    return data
  }

  public func set(data: Data, for key: String) throws {
    cache[key] = data

    var params = makeParameters(for: key)

    // Attempt to update the entry
    var status = SecItemUpdate(
      params as CFDictionary,
      [kSecValueData: data] as CFDictionary)

    // If it doesn't exist, try adding it
    if status == errSecItemNotFound {
      params[kSecAttrAccessible] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
      params[kSecValueData] = data
      status = SecItemAdd(params as CFDictionary, nil)
    }

    guard status == errSecSuccess else {
      throw Error.keychain(status)
    }
  }

  public func removeData(for key: String) throws {
    cache[key] = nil

    let params = makeParameters(for: key)
    let status = SecItemDelete(params as CFDictionary)

    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw Error.keychain(status)
    }
  }

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

  // MARK: - Reset Operations

  public func reset() throws {
    cache = [:]

    var query = makeParameters(for: nil)
#if os(macOS)
    query[kSecMatchLimit] = kSecMatchLimitAll
#endif

    let status = SecItemDelete(query as CFDictionary)

    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw Error.keychain(status)
    }
  }

  // MARK: - Errors
  public enum Error: Swift.Error {
    /// Represents a keychain operation error with the associated OSStatus code
    case keychain(OSStatus)
  }

  // MARK: - Public Extensions for Common Types

  public func bool(for key: String) throws -> Bool? {
    try value(for: key) as? Bool
  }

  public func set(bool: Bool, for key: String) throws {
    try set(value: bool, for: key)
  }

  public func int(for key: String) throws -> Int? {
    try value(for: key) as? Int
  }

  public func set(int: Int, for key: String) throws {
    try set(value: int, for: key)
  }

  // MARK: - Private Helpers

  private func makeParameters(for key: String?) -> [CFString: Any] {
    var query: [CFString: Any] = [
      kSecAttrGeneric: Data(self.identifier.utf8),
      kSecClass: kSecClassGenericPassword,
    ]
    if let key {
      query[kSecAttrService] = key
    }
    return query
  }
}
