#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT

struct FlatObjectArrayJWT: JWT, Codable, Equatable {

  enum CodingKeys: String, CodingKey {
    case array = "array_key"
  }

  struct Nested: Codable, Equatable {
    let testKey1: String?
    let testKey2: String?

    enum CodingKeys: String, CodingKey {
      case testKey1 = "test_key_1"
      case testKey2 = "test_key_2"
    }
  }

  let type: String? = "flatObjectArray"

  let array: [Nested]
}

extension FlatObjectArrayJWT: Mockable {

  struct Mock {

    // MARK: Internal

    static let payload = FlatObjectArrayJWT(
      array:
      [
        Nested(testKey1: "test_value_1", testKey2: "test_value_2"),
        Nested(testKey1: "test_value_3", testKey2: "test_value_4"),
      ])
    static let oneDisclosedElementData = oneDisclosedElementJWS.sdJWSData(with: [disclosureElement2])
    static let fullyDisclosedData = fullyDisclosedJWS.sdJWSData(with: [disclosureElement1, disclosureElement2])

    /// ["test_salt_1", {"test_key_1":"test_value_1", "test_key_2":"test_value_2"}]
    /// 6KyeusuhLExIaIKOx2ejZE9776pTDf1cQjnraJfAV94
    static let disclosureElement1 = "WyJ0ZXN0X3NhbHRfMSIsIHsidGVzdF9rZXlfMSI6InRlc3RfdmFsdWVfMSIsICJ0ZXN0X2tleV8yIjoidGVzdF92YWx1ZV8yIn1d"

    /// ["test_salt_2", {"test_key_1":"test_value_3", "test_key_2":"test_value_4"}]
    /// V4cLLcpCfh_E_dvB3bgSGJCVwwKYclks5CNtApcwZEg
    static let disclosureElement2 = "WyJ0ZXN0X3NhbHRfMiIsIHsidGVzdF9rZXlfMSI6InRlc3RfdmFsdWVfMyIsICJ0ZXN0X2tleV8yIjoidGVzdF92YWx1ZV80In1d"

    // MARK: Private

    /**
     {
       "array_key": [
         {
           "test_key_1": "test_value_1",
           "test_key_2": "test_value_2"
         },
         {
           "...": "V4cLLcpCfh_E_dvB3bgSGJCVwwKYclks5CNtApcwZEg"
         }
       ],
       "_sd_alg": "sha-256"
     }
     */
    private static let oneDisclosedElementJWS = "eyJ0eXAiOiJmbGF0T2JqZWN0QXJyYXkiLCJhbGciOiJFUzUxMiJ9.eyJhcnJheV9rZXkiOlt7InRlc3Rfa2V5XzEiOiJ0ZXN0X3ZhbHVlXzEiLCJ0ZXN0X2tleV8yIjoidGVzdF92YWx1ZV8yIn0seyIuLi4iOiJWNGNMTGNwQ2ZoX0VfZHZCM2JnU0dKQ1Z3d0tZY2xrczVDTnRBcGN3WkVnIn1dLCJfc2RfYWxnIjoic2hhLTI1NiJ9.AKd8UH-guoIeCC4S8bUlROeTk49y82vME0foiBoPaLFB7s72Wn3_W1essa94H1FXgxNxaqACpHWWLnrJd_sHQFcIAQkS4P3gzy-mc_ebV1Wn5qNhwWYZLqA39MBy3TGyg8RWpuaR_HZ3X1lGs8Gh_FdR_wfLsU6MvxB7wffDf-C7t8N-"

    /**
     {
        "array_key":[
           {
              "...":"6KyeusuhLExIaIKOx2ejZE9776pTDf1cQjnraJfAV94"
           },
           {
              "...":"V4cLLcpCfh_E_dvB3bgSGJCVwwKYclks5CNtApcwZEg"
           }
        ],
        "_sd_alg":"sha-256"
     }
     */
    private static let fullyDisclosedJWS = "eyJ0eXAiOiJmbGF0T2JqZWN0QXJyYXkiLCJhbGciOiJFUzUxMiJ9.eyJhcnJheV9rZXkiOlt7Ii4uLiI6IjZLeWV1c3VoTEV4SWFJS094MmVqWkU5Nzc2cFREZjFjUWpucmFKZkFWOTQifSx7Ii4uLiI6IlY0Y0xMY3BDZmhfRV9kdkIzYmdTR0pDVnd3S1ljbGtzNUNOdEFwY3daRWcifV0sIl9zZF9hbGciOiJzaGEtMjU2In0.ALoF8WV5SShn3mfHnJWOptsULkIO_RgTm9PUux7rbJdf0gfGJcp9QgORaSsOvUwZxr33YRPsBiLCTddbEPd_co4bALM2PoWzoTaUnOalTl5fUvQCyx5KGbkRXAZfBclsua4fc_ocbbpXQtqKQDeo1SqWMWLR2FG96zN2TF4OJsqDAvUm"
  }
}

extension FlatObjectArrayJWT {
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
