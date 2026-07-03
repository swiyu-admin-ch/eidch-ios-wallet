#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT

struct FlatSimpleArrayJWT: JWT, Codable, Equatable {

  // MARK: Lifecycle

  init(testValue1: String? = nil, array: [String] = []) {
    self.testValue1 = testValue1
    self.array = DisclosableArray(array)
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case testValue1 = "test_key_1"
    case array = "array_key"
  }

  let type: String? = "flatSimpleArray"

  let testValue1: String?
  let array: DisclosableArray<String>
}

extension FlatSimpleArrayJWT: Mockable {

  struct Mock {

    // MARK: Internal

    static let otherClaimsPayload = FlatSimpleArrayJWT(testValue1: "test_value_1", array: ["test_array_value_1", "test_array_value_2"])
    static let otherClaimsData = otherClaimsJWS.sdJWSData(with: [disclosure1, disclosureElement2])
    static let arrayOnlyPayload = FlatSimpleArrayJWT(array: ["test_array_value_1", "test_array_value_2"])
    static let arrayOnlyData = arrayOnlyJWS.sdJWSData(with: [disclosureElement1, disclosureElement2])
    static let arrayWithDecoysData = arrayOnlyJWS.sdJWSData(with: [disclosureElement1])

    /// ["test_salt_1", "test_key_1", "test_value_1"]
    /// YRLf606clwt4-hjyGze49ySFi6VCmwb9n5hwb4VUJSY
    static let disclosure1 = "WyJ0ZXN0X3NhbHRfMSIsICJ0ZXN0X2tleV8xIiwgInRlc3RfdmFsdWVfMSJd"

    /// ["test_salt", "test_array_value_1"]
    /// bgUmES59QYf9VR8IbgJy3LpbXWMrwEaoblSFS3poqEg
    static let disclosureElement1 = "WyJ0ZXN0X3NhbHQiLCAidGVzdF9hcnJheV92YWx1ZV8xIl0"

    /// ["test_salt", "test_array_value_2"]
    /// HWWQ_E69DRWp7FhCHyQdS01ushRMA9GXJpzh5DosDHU
    static let disclosureElement2 = "WyJ0ZXN0X3NhbHQiLCAidGVzdF9hcnJheV92YWx1ZV8yIl0"

    // MARK: Private

    /**
      {
         "_sd":[
            "YRLf606clwt4-hjyGze49ySFi6VCmwb9n5hwb4VUJSY"
         ],
         "array_key":[
            "test_array_value_1",
            {
               "...":"HWWQ_E69DRWp7FhCHyQdS01ushRMA9GXJpzh5DosDHU"
            }
         ],
         "_sd_alg":"sha-256"
      }
     */
    private static let otherClaimsJWS = "eyJhbGciOiJFUzUxMiIsInR5cCI6ImZsYXRTaW1wbGVBcnJheSJ9.eyJfc2QiOlsiWVJMZjYwNmNsd3Q0LWhqeUd6ZTQ5eVNGaTZWQ213YjluNWh3YjRWVUpTWSJdLCJhcnJheV9rZXkiOlsidGVzdF9hcnJheV92YWx1ZV8xIix7Ii4uLiI6IkhXV1FfRTY5RFJXcDdGaENIeVFkUzAxdXNoUk1BOUdYSnB6aDVEb3NESFUifV0sIl9zZF9hbGciOiJzaGEtMjU2In0.AUqpLgj_vWB0uQd10iEQeQ0laxct2FoF-Q-3Fjn8hfkh_v0_h6zI_xgEJQ9rFSwy4t0HO-fz3JM9_ILl2nmuhDjLAU3P8j3B5JkrBndXfIsXYIfjoVHXHaUWtcyYHRJP56b2wBRNWedW5U6fXofye8febKowcHPxMa88AwzLnjtBTmZv"

    /**
      {
         "array_key":[
            {
               "...":"bgUmES59QYf9VR8IbgJy3LpbXWMrwEaoblSFS3poqEg"
            },
            {
               "...":"HWWQ_E69DRWp7FhCHyQdS01ushRMA9GXJpzh5DosDHU"
            }
         ],
         "_sd_alg":"sha-256"
      }
     */
    private static let arrayOnlyJWS = "eyJhbGciOiJFUzUxMiIsInR5cCI6ImZsYXRTaW1wbGVBcnJheSJ9.eyJhcnJheV9rZXkiOlt7Ii4uLiI6ImJnVW1FUzU5UVlmOVZSOEliZ0p5M0xwYlhXTXJ3RWFvYmxTRlMzcG9xRWcifSx7Ii4uLiI6IkhXV1FfRTY5RFJXcDdGaENIeVFkUzAxdXNoUk1BOUdYSnB6aDVEb3NESFUifV0sIl9zZF9hbGciOiJzaGEtMjU2In0.AXSHFCY1B41ShTt-3OkQKKkArEsvGhkUfdTCk1jBE8Ry3lSkBJh0NfU3F5fU0ik-d-bGpJbG08GUlTe-YiGJCxCjAfiNJ2FbqPP72HbyaoOLs6rNjhl3pXAmrX8h0hOTcz28_V1E7kjt1srVx1b550-vWh1RoA_RcvQ_OFbtNuvuniHb"
  }
}

extension FlatSimpleArrayJWT {
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
