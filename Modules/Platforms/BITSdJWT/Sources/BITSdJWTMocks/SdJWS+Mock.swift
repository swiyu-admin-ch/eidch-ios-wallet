#if DEBUG
import Foundation
@testable import BITJWT
@testable import BITSdJWT
@testable import BITTestingCore

struct TestSdJWTPayload: JWTPayload, Codable, Equatable {

  // MARK: Lifecycle

  public init(
    testValue1: String? = nil,
    testValue2: String? = nil,
    testValue3: String? = nil)
  {
    self.testValue1 = testValue1
    self.testValue2 = testValue2
    self.testValue3 = testValue3
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case testValue1 = "test_key_1"
    case testValue2 = "test_key_2"
    case testValue3 = "test_key_3"
  }

  let type: String? = "test"

  let testValue1: String?
  let testValue2: String?
  let testValue3: String?

}

extension TestSdJWTPayload: Mockable {

  struct Mock {

    // MARK: Internal

    static let samplePayload = TestSdJWTPayload(testValue1: "test_value_1", testValue2: "test_value_2", testValue3: "test_value_3")

    static let flat: SdJWS<TestSdJWTPayload> = createSdJWT(from: flatJwtData)
    static let flatJwtData: Data = getData(fromFile: "sd-jwt-flat", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let flatJwtPayload: String = getString(fromFile: "sd-jwt-flat-payload", ofType: "json", bundle: Bundle.module)
    static let flatJwtWithIsoDateData: Data = getData(fromFile: "sd-jwt-flat-with-iso-date", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let flatJwtWithIsoDatePayload: String = getString(fromFile: "sd-jwt-flat-with-iso-date-payload", ofType: "json", bundle: Bundle.module)
    static let flatJwtWithKeyBindingData: Data = getData(fromFile: "sd-jwt-flat-with-keybinding", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let flatJwtUsingSha384: Data = getData(fromFile: "sd-jwt-flat-using-sha-384", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let flatJwtUsingSha512: Data = getData(fromFile: "sd-jwt-flat-using-sha-512", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let undisclosedJwtData: Data = getData(fromFile: "sd-jwt-undisclosed", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let undisclosedJwtPayload: String = getString(fromFile: "sd-jwt-undisclosed-payload", ofType: "json", bundle: Bundle.module)
    static let undisclosedJwtWithKeyBindingData: Data = getData(fromFile: "sd-jwt-undisclosed-with-keybinding", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let unsupportedDigestAlgorithmData: Data = getData(fromFile: "sd-jwt-unsupported-digest-algorithm", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let invalidDigestsData: Data = getData(fromFile: "sd-jwt-invalid-digests", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let duplicateDigestData: Data = getData(fromFile: "sd-jwt-duplicate-digest", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let digestNotFoundData: Data = getData(fromFile: "sd-jwt-digest-not-found", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let claimAlreadyExistsData: Data = getData(fromFile: "sd-jwt-claim-already-exists", ofType: "txt", bundle: Bundle.module) ?? Data()

    static let digest1 = "YRLf606clwt4-hjyGze49ySFi6VCmwb9n5hwb4VUJSY"
    static let digest2 = "QhuvIMQd5LyX8gOR3weVzSY0yGZGGHdVXY0E-NhhUfw"
    static let digest3 = "ql6yBMb-5Ql1gG833J1o3poFIDLVt9Ck79astQeVYb0"
    static let digests = [digest1, digest2, digest3]
    // ["test_salt_1", "test_key_1", "test_value_1"]
    static let disclosure1 = "WyJ0ZXN0X3NhbHRfMSIsICJ0ZXN0X2tleV8xIiwgInRlc3RfdmFsdWVfMSJd"
    // ["test_salt_2", "test_key_2", "test_value_2"]
    static let disclosure2 = "WyJ0ZXN0X3NhbHRfMiIsICJ0ZXN0X2tleV8yIiwgInRlc3RfdmFsdWVfMiJd"
    // ["test_salt_3", "test_key_3", "test_value_3"]
    static let disclosure3 = "WyJ0ZXN0X3NhbHRfMyIsICJ0ZXN0X2tleV8zIiwgInRlc3RfdmFsdWVfMyJd"
    static let disclosures = [disclosure1, disclosure2, disclosure3]

    // MARK: Private

    private static func createSdJWT(from data: Data) -> SdJWS<TestSdJWTPayload> {
      // swiftlint: disable force_try
      try! SdJWSDecoder().decode(TestSdJWTPayload.self, from: data)
      // swiftlint: enable force_try
    }
  }
}
#endif
