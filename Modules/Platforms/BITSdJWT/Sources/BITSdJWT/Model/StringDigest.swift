import BITCrypto
import Foundation

// MARK: - StringDigest

struct StringDigest {

  let content: String

  func createDigest(algorithm: Algorithm) throws -> String {
    guard let data = content.data(using: .ascii) else {
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

// MARK: StringDigest.Algorithm

extension StringDigest {
  enum Algorithm: String {
    case sha256 = "sha-256"
    case sha384 = "sha-384"
    case sha512 = "sha-512"

    func hash(data: Data) -> Data {
      switch self {
      case .sha256:
        SHA256Hasher().hash(data)
      case .sha384:
        SHA384Hasher().hash(data)
      case .sha512:
        SHA512Hasher().hash(data)
      }
    }
  }
}
