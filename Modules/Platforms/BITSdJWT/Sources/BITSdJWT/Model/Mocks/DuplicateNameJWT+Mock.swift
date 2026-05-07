#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT

struct DuplicateNameJWT: JWT, Codable, Equatable {

  enum CodingKeys: String, CodingKey {
    case testKey1 = "test_key_1"
    case testKey2 = "test_key_2"
    case testKey3 = "test_key_3"
  }

  struct Nested1: Codable, Equatable {
    let key: String?

    enum CodingKeys: String, CodingKey {
      case key = "test_key_1"
    }
  }

  struct Nested2: Codable, Equatable {
    let key: String?

    enum CodingKeys: String, CodingKey {
      case key = "test_key_2"
    }
  }

  let type: String? = "duplicateName"

  let testKey1: String
  let testKey2: Nested1?
  let testKey3: Nested2

}

extension DuplicateNameJWT: Mockable {

  struct Mock {

    // MARK: Internal

    static let payload = DuplicateNameJWT(testKey1: "test_value_1", testKey2: Nested1(key: "test_value_2"), testKey3: Nested2(key: "test_value_3"))
    /**
     {
        "test_key_1":"test_value_1",
        "_sd":[
           "pk1w7C8cLpOhgTNaNeDl9vUSo310MBXk45zK19QWdTw"
        ],
        "test_key_3":{
           "_sd":[
              "E-wMMHgkmMG_OdAwhuilssUfAv_NFcTQH4DT9tmyXVk"
           ]
        },
        "_sd_alg":"sha-256"
     }
     */
    static let JWS = "eyJ0eXAiOiJkdXBsaWNhdGVOYW1lIiwiYWxnIjoiRVM1MTIifQ.eyJ0ZXN0X2tleV8xIjoidGVzdF92YWx1ZV8xIiwiX3NkIjpbInBrMXc3QzhjTHBPaGdUTmFOZURsOXZVU28zMTBNQlhrNDV6SzE5UVdkVHciXSwidGVzdF9rZXlfMyI6eyJfc2QiOlsiRS13TU1IZ2ttTUdfT2RBd2h1aWxzc1VmQXZfTkZjVFFINERUOXRteVhWayJdfSwiX3NkX2FsZyI6InNoYS0yNTYifQ.AShV6_mtqeGsORdoLEf5MT_ggoOdchpVvbpR7yvcAQzluQMmGns6KYzV5k2cBU3wMeNT_W40HCreVjnhWuPRZrZ6ARDfrOCgGEEHwQur_tfDmFvMvx_7rlFj2FGkz5koOChaw7oSqAtmWm0H1R9J4HSMtF4ZoQQkg06LVcqKDpNZzAzY"
    static let data = JWS.sdJWSData(with: disclosures)

    // MARK: Private

    /// ["test_salt_1", "test_key_1", "test_value_2"]
    /// wKj4p6UpMHCEGnR2MuSlL1OQ6SGI_-am1i2lu1fv5cw
    private static let disclosure1 = "WyJ0ZXN0X3NhbHRfMSIsICJ0ZXN0X2tleV8xIiwgInRlc3RfdmFsdWVfMiJd"

    /// ["test_salt_2", "test_key_2", "test_value_3"]
    /// E-wMMHgkmMG_OdAwhuilssUfAv_NFcTQH4DT9tmyXVk
    private static let disclosure2 = "WyJ0ZXN0X3NhbHRfMiIsICJ0ZXN0X2tleV8yIiwgInRlc3RfdmFsdWVfMyJd"

    /// ["test_salt_3", "test_key_2", {"_sd":["wKj4p6UpMHCEGnR2MuSlL1OQ6SGI_-am1i2lu1fv5cw"]}]
    /// pk1w7C8cLpOhgTNaNeDl9vUSo310MBXk45zK19QWdTw
    private static let disclosureNested =
      "WyJ0ZXN0X3NhbHRfMyIsICJ0ZXN0X2tleV8yIiwgeyJfc2QiOlsid0tqNHA2VXBNSENFR25SMk11U2xMMU9RNlNHSV8tYW0xaTJsdTFmdjVjdyJdfV0"
    private static let disclosures = [disclosure1, disclosure2, disclosureNested]
  }
}

extension DuplicateNameJWT {
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
