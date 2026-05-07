import Foundation

extension String {

  func digest(algorithm: StringDigest.Algorithm) throws -> SdJwtDigest {
    try StringDigest(content: self).createDigest(algorithm: algorithm)
  }

}
