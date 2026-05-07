#if DEBUG
import Foundation
@testable import BITJWT

struct PartFlatJWT: JWT, Codable, Equatable {

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case testKey1 = "test_key_1"
    case testKey2 = "test_key_2"
  }

  let type: String? = "flat"

  let testKey1: String?
  let testKey2: String?
}

extension PartFlatJWT {
  var issuer: String? {
    nil
  }

  var audience: String? {
    nil
  }

  var subject: String? {
    nil
  }

  var issuedAt: Date? {
    nil
  }

  var expiredAt: Date? {
    nil
  }

  var activatedAt: Date? {
    nil
  }
}
#endif
