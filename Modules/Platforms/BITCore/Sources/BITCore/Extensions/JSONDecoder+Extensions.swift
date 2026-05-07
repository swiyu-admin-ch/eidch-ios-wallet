import Foundation

extension JSONDecoder {

  public convenience init(dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .iso8601) {
    self.init()
    self.dateDecodingStrategy = dateDecodingStrategy
  }
}

#if DEBUG
extension JSONDecoder {

  static func decode<D: Decodable>(_ data: Data, dateFormat: JSONDecoder.DateDecodingStrategy = .iso8601) throws -> D {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = dateFormat
    return try decoder.decode(D.self, from: data)
  }

  static func decode<T: Decodable>(from string: String, onDecodingError error: Error) throws -> T {
    guard let data = string.data(using: .utf8) else { throw error }
    return try JSONDecoder().decode(T.self, from: data)
  }
}
#endif
