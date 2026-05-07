#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT

struct IsoJWT: JWT, Codable, Equatable {

  enum CodingKeys: String, CodingKey {
    case date
  }

  let type: String? = "iso"

  let date: Date?
}

extension IsoJWT: Mockable {

  struct Mock {
    /// ["salt_date", "date", "2001-01-01T00:00:00Z"]
    /// Ba0DsbQZLMQGvGarurfAIXuo2qGzcQuw5kV3_tbNzKY
    private static let disclosure = "WyJzYWx0X2RhdGUiLCAiZGF0ZSIsICIyMDAxLTAxLTAxVDAwOjAwOjAwWiJd"

    static let payload = IsoJWT(date: Date(timeIntervalSinceReferenceDate: 0))
    /**
     {
       "_sd": [
         "Ba0DsbQZLMQGvGarurfAIXuo2qGzcQuw5kV3_tbNzKY"
       ],
       "_sd_alg": "sha-256"
     }
     */
    private static let JWS = "eyJhbGciOiJFUzUxMiIsInR5cCI6ImlzbyJ9.eyJfc2QiOlsiQmEwRHNiUVpMTVFHdkdhcnVyZkFJWHVvMnFHemNRdXc1a1YzX3RiTnpLWSJdLCJfc2RfYWxnIjoic2hhLTI1NiJ9.Ac8rUoa1nnjHKz12FOnbUjxL7xVBj6GLsmhkB7YpjiAXupJpqZg4R3iySIYp44S9M_su44pcyeMzFiSz1-7nmI2_AXI836-YaEpRgSruxQyEyS4icTimr5-yMoSFZybOVPL2ryPdgH6HXmW5jekffyj26DuUWdDSHv7ezzGIKO3Gv4Lk"
    static let data = JWS.sdJWSData(with: [disclosure])
  }
}

extension IsoJWT {
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
