import Foundation
import Spyable

// MARK: - SecretManagerProtocol

@Spyable
public protocol SecretManagerProtocol: Sendable {
  func string(forKey key: String, query: Query?) -> String?
  func integer(forKey key: String, query: Query?) -> Int?
  func double(forKey key: String, query: Query?) -> Double?
  func bool(forKey key: String, query: Query?) -> Bool?
  func data(forKey key: String, query: Query?) -> Data?
  func removeObject(forKey key: String, query: Query?) throws
  func set(_ value: Any?, forKey key: String, query: Query?) throws
  func exists(key: String, query: Query?) -> Bool
}

extension SecretManagerProtocol {

  public func string(forKey key: String, query: Query? = nil) -> String? {
    string(forKey: key, query: query)
  }

  public func double(forKey key: String, query: Query? = nil) -> Double? {
    double(forKey: key, query: query)
  }

  public func bool(forKey key: String, query: Query? = nil) -> Bool? {
    bool(forKey: key, query: query)
  }

  public func data(forKey key: String, query: Query? = nil) -> Data? {
    data(forKey: key, query: query)
  }

  public func integer(forKey key: String, query: Query? = nil) -> Int? {
    integer(forKey: key, query: query)
  }

  public func removeObject(forKey key: String, query: Query? = nil) throws {
    try removeObject(forKey: key, query: query)
  }

  public func set(_ value: Any?, forKey key: String, query: Query? = nil) throws {
    try set(value, forKey: key, query: query)
  }

  public func exists(key: String, query: Query? = nil) -> Bool {
    exists(key: key, query: query)
  }

}
