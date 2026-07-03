import BITCrypto
import Foundation

// MARK: - SdJwtDigestAlgorithm

public enum SdJwtDigestAlgorithm: String {
  case sha256 = "sha-256"

  public func hash(data: Data) -> Data {
    switch self {
    case .sha256: SHA256Hasher().hash(data)
    }
  }
}
