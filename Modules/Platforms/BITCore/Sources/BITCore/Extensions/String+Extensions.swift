import Foundation

extension String {

  // MARK: Public

  public var base64Decoded: String? {
    var finalBase64String = self
    let remainder = finalBase64String.count % 4
    if remainder != 0 {
      let paddingLength = 4 - remainder
      finalBase64String += String(repeating: "=", count: paddingLength)
    }

    guard
      let decodedData = Data(base64Encoded: finalBase64String),
      let decodedString = String(data: decodedData, encoding: .utf8)
    else { return nil }
    return decodedString
  }

  public var base64Encoded: String? {
    data(using: .utf8)?.base64EncodedString()
  }

  public var base64EncodedURLSafe: String {
    replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")
  }

  public func toJsonObject() throws -> Any? {
    guard let data = data(using: .utf8) else {
      throw DataConversionError.stringEncodingFailed
    }
    return try JSONSerialization.customJsonObject(with: data, options: [.fragmentsAllowed])
  }

  // MARK: Internal

  enum DataConversionError: Error {
    case stringEncodingFailed
  }
}
