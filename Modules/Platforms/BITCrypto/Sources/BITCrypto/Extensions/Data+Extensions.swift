import CryptoKit
import Foundation

extension Data {

  // MARK: Lifecycle

  public init?(base64URLEncoded string: String) {
    var base64 = string
      .replacingOccurrences(of: "-", with: "+")
      .replacingOccurrences(of: "_", with: "/")

    switch base64.count % 4 {
    case 0: break
    case 2: base64.append("==")
    case 3: base64.append("=")
    default: return nil
    }

    self.init(base64Encoded: base64)
  }

  // MARK: Public

  public var hexString: String {
    map { String(format: "%02hhx", $0) }.joined()
  }

  /// Generate randomly an array of bytes and return it as Data object
  /// - Parameters:
  ///   - length:the length of the bytes array to generate in bytes
  public static func random(length: Int) throws -> Data {
    var randomBytes = [Int8](repeating: 0, count: length)
    let status = SecRandomCopyBytes(kSecRandomDefault, length, &randomBytes)
    guard status == errSecSuccess else {
      throw DataGenerationError.cannotGenerateRandomBytes
    }
    return Data(bytes: randomBytes, count: length)
  }

  public func base64URLEncodedString() -> String {
    let s = base64EncodedString()
    return s
      .replacingOccurrences(of: "=", with: "")
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
  }

  // MARK: Internal

  static func combine(_ data: Data, with anotherData: Data) -> Data {
    data + anotherData
  }

  // MARK: Private

  private enum DataGenerationError: Error {
    case cannotGenerateRandomBytes
  }

}
