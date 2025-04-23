import Foundation

extension String {

  func digest(algorithm: StringDigest.Algorithm) throws -> String {
    try StringDigest(content: self).createDigest(algorithm: algorithm)
  }

}
