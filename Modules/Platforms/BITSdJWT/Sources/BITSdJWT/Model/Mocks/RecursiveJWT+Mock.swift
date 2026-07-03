#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT

struct RecursiveJWT: JWT, Codable, Equatable {

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case key = "test_key_1"
  }

  struct Nested: Codable, Equatable {
    let key: String?

    enum CodingKeys: String, CodingKey {
      case key = "test_key_2"
    }
  }

  let type: String? = "recursive"

  let key: Nested?
}

extension RecursiveJWT: Mockable {

  struct Mock {

    // MARK: Internal

    static let payload = RecursiveJWT(key: Nested(key: "test_value_2"))
    /**
     {
       "_sd": [
         "EieNhILyn4oeWiVzOIGvy3shkJgwApK4OzLTRnqU8rY"
       ],
       "_sd_alg": "sha-256"
     }
     */
    static let JWS = "eyJ0eXAiOiJyZWN1cnNpdmUiLCJhbGciOiJFUzUxMiJ9.eyJfc2QiOlsiRWllTmhJTHluNG9lV2lWek9JR3Z5M3Noa0pnd0FwSzRPekxUUm5xVThyWSJdLCJfc2RfYWxnIjoic2hhLTI1NiJ9.AIseB9SQD3kpzAzsvka_pmZ4uMh9ir42ofmcnZVgKv3cG4dRFweqxJDs6w8oz904B3XxidHWfC0p5U9gi3W68jy6AMYhp0Jg5tPuTKrFLOLx7VxZ3xD9A4_j01Ty0z6mYfNp12nC8mqYHWqh60VEGToN5nNN0RXHmPD5Y0R50Ioh1fFD"
    static let data = JWS.sdJWSData(with: disclosures)

    /**
     [
        "test_salt_1",
        "test_key_1",
        {
           "_sd":[
              "QhuvIMQd5LyX8gOR3weVzSY0yGZGGHdVXY0E-NhhUfw" // digest of disclosure 2
           ]
        }
     ]
     */
    /// EieNhILyn4oeWiVzOIGvy3shkJgwApK4OzLTRnqU8rY
    static let disclosure1 = "WwogICAidGVzdF9zYWx0XzEiLAogICAidGVzdF9rZXlfMSIsCiAgIHsKICAgICAgIl9zZCI6WwogICAgICAgICAiUWh1dklNUWQ1THlYOGdPUjN3ZVZ6U1kweUdaR0dIZFZYWTBFLU5oaFVmdyIKICAgICAgXQogICB9Cl0"

    /// ["test_salt_2", "test_key_2", "test_value_2"]
    /// QhuvIMQd5LyX8gOR3weVzSY0yGZGGHdVXY0E-NhhUfw
    static let disclosure2 = "WyJ0ZXN0X3NhbHRfMiIsICJ0ZXN0X2tleV8yIiwgInRlc3RfdmFsdWVfMiJd"

    // MARK: Private

    private static let disclosures = [disclosure1, disclosure2]
  }
}

extension RecursiveJWT {
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
