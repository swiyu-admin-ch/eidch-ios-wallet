import CryptoKit
import Foundation

public struct ImageHasher {

  public static func hash(from imageData: Data?) -> String? {
    guard let imageData else { return nil }
    return hash(imageData)
  }

  public static func hash(_ imageData: Data) -> String {
    let digest = SHA256.hash(data: imageData)
    // map data to 2-digit lowercase hex String
    return digest.map { String(format: "%02x", $0) }.joined()
  }
}
