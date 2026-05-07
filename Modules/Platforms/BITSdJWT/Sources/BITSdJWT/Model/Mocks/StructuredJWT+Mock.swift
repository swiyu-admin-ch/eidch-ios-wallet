#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT

struct StructuredJWT: JWT, Codable, Equatable {

  enum CodingKeys: String, CodingKey {
    case test
  }

  struct Nested: Codable, Equatable {
    let testKey1: String?
    let testKey2: String?

    enum CodingKeys: String, CodingKey {
      case testKey1 = "test_key_1"
      case testKey2 = "test_key_2"
    }
  }

  let type: String? = "structured"

  let test: Nested?
}

extension StructuredJWT: Mockable {

  struct Mock {

    // MARK: Internal

    static let payload = StructuredJWT(test: Nested(testKey1: "test_value_1", testKey2: "test_value_2"))
    /**
     {
       "test": {
         "_sd": [
           "YRLf606clwt4-hjyGze49ySFi6VCmwb9n5hwb4VUJSY",
           "QhuvIMQd5LyX8gOR3weVzSY0yGZGGHdVXY0E-NhhUfw"
         ]
       },
       "_sd_alg": "sha-256"
     }
     */
    static let JWS = "eyJ0eXAiOiJzdHJ1Y3R1cmVkIiwiYWxnIjoiRVM1MTIifQ.eyJ0ZXN0Ijp7Il9zZCI6WyJZUkxmNjA2Y2x3dDQtaGp5R3plNDl5U0ZpNlZDbXdiOW41aHdiNFZVSlNZIiwiUWh1dklNUWQ1THlYOGdPUjN3ZVZ6U1kweUdaR0dIZFZYWTBFLU5oaFVmdyJdfSwiX3NkX2FsZyI6InNoYS0yNTYifQ.AUD8pZhe2-1sx5A0v0p8amxjkHPgKkzvC1QHfg3KR8LjS7ej8TQRcfKM7WzpA33lXrkAZh7DATRG4ICJao66HuvNAegi7QRff6-y9S1y5ZFZxNqzPci5kUA4Hy50RiquODRE6V3L95Fx2fk49iviZCiuiB9uMVOGXy_1z6MY9eEYHtl2"
    static let data = JWS.sdJWSData(with: disclosures)
    static let dataWithKeyBinding = JWS.sdJWSData(with: disclosures, keyBindingJWT: "KEY.BINDING.JWT")

    // MARK: Private

    /// ["test_salt_1", "test_key_1", "test_value_1"]
    /// YRLf606clwt4-hjyGze49ySFi6VCmwb9n5hwb4VUJSY
    private static let disclosure1 = "WyJ0ZXN0X3NhbHRfMSIsICJ0ZXN0X2tleV8xIiwgInRlc3RfdmFsdWVfMSJd"

    /// ["test_salt_2", "test_key_2", "test_value_2"]
    /// QhuvIMQd5LyX8gOR3weVzSY0yGZGGHdVXY0E-NhhUfw
    private static let disclosure2 = "WyJ0ZXN0X3NhbHRfMiIsICJ0ZXN0X2tleV8yIiwgInRlc3RfdmFsdWVfMiJd"
    private static let disclosures = [disclosure1, disclosure2]
  }
}

extension StructuredJWT {
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
