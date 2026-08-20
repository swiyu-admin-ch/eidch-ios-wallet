// swiftlint:disable force_cast
import BITCore
import Foundation

extension Data {
  public func changeJsonPayload(with dictionary: [String: Any]) throws -> Data {
    var jsonDictionary = try JSONSerialization.jsonObject(with: self) as! JSON
    jsonDictionary.merge(dictionary) { _, second in
      second
    }
    return try JSONSerialization.data(withJSONObject: jsonDictionary)
  }

  public func removeJsonKey(_ key: String) throws -> Data {
    var dictionary = try JSONSerialization.jsonObject(with: self) as! JSON
    dictionary.removeValue(forKey: key)
    return try JSONSerialization.data(withJSONObject: dictionary)
  }
}
