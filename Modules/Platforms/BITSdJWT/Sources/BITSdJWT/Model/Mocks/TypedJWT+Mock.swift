#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT

struct TypedJWT: JWT, Codable, Equatable {

  enum CodingKeys: String, CodingKey {
    case number = "key_number"
    case boolean = "key_boolean"
    case null = "key_null"
  }

  let type: String? = "typed"

  let number: Int?
  let boolean: Bool?
  let null: Int? = nil
}

extension TypedJWT: Mockable {

  struct Mock {

    // MARK: Internal

    static let payload = TypedJWT(number: 42, boolean: true)
    static let data = JWS.sdJWSData(with: disclosures)

    // MARK: Private

    /// ["salt_number", "key_number", 42]
    /// shlXUWLol2Dqa6w-hNHnIeuEgPdB25svAe5-BnPT1a4
    private static let numberDisclosure = "WyJzYWx0X251bWJlciIsICJrZXlfbnVtYmVyIiwgNDJd"

    /// ["salt_boolean", "key_boolean", true]
    /// 8E9yFMJMl7WfdxTKPSRWHOfpirT-udb3r3rLCw8f7qc
    private static let booleanDisclosure = "WyJzYWx0X2Jvb2xlYW4iLCAia2V5X2Jvb2xlYW4iLCB0cnVlXQ"

    /// ["salt_null", "key_null", null]
    /// elB_obeWnlIBhWYILJTVZpbmTrAYwCTjPZa22VBgB70
    private static let nullDisclosure = "WyJzYWx0X251bGwiLCAia2V5X251bGwiLCBudWxsXQ"
    private static let disclosures = [numberDisclosure, booleanDisclosure, nullDisclosure]

    /**
     {
       "_sd": [
         "shlXUWLol2Dqa6w-hNHnIeuEgPdB25svAe5-BnPT1a4",
         "8E9yFMJMl7WfdxTKPSRWHOfpirT-udb3r3rLCw8f7qc",
         "elB_obeWnlIBhWYILJTVZpbmTrAYwCTjPZa22VBgB70"
       ],
       "_sd_alg": "sha-256"
     }
     */
    private static let JWS = "eyJhbGciOiJFUzUxMiIsInR5cCI6InR5cGVkIn0.eyJfc2QiOlsic2hsWFVXTG9sMkRxYTZ3LWhOSG5JZXVFZ1BkQjI1c3ZBZTUtQm5QVDFhNCIsIjhFOXlGTUpNbDdXZmR4VEtQU1JXSE9mcGlyVC11ZGIzcjNyTEN3OGY3cWMiLCJlbEJfb2JlV25sSUJoV1lJTEpUVlpwYm1UckFZd0NUalBaYTIyVkJnQjcwIl0sIl9zZF9hbGciOiJzaGEtMjU2In0.ALp-zljx5YKyMZRKXv_v39mz4gZ4Ft-dqikYEerEWX53ehz_g9oUin5--MAYG0FrnifcgIgdAvr3UTmOeRvJLBiLAMInlJAiOdkSvfctWpd9_-vaf6cUO9EMXqOkYcqbW60qEQoMyVGYqCBcdQTqUW4d0rtHe0hfFDMlGvAss_5oYHxq"
  }
}

extension TypedJWT {
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
