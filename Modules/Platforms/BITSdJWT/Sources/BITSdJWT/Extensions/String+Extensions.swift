import Foundation

extension String {

  func digest(algorithm: SdJwtDigestAlgorithm) throws -> SdJwtDigest {
    guard let data = data(using: .ascii) else {
      throw DecodingError.dataCorrupted(DecodingError.Context(
        codingPath: [],
        debugDescription: "The string cannot be encoded using ASCII."))
    }

    let digest = algorithm.hash(data: data)
    var base64String = digest.base64EncodedString()
    base64String = base64String
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "/", with: "_")
      .trimmingCharacters(in: CharacterSet(charactersIn: "="))

    return base64String
  }

}
