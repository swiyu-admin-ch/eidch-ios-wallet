#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT
@testable import BITSdJWT
@testable import BITTestingCore

// swiftlint:disable force_try

extension VcSdJwtPayload: Mockable {

  struct Mock {

    // MARK: Internal

    static let sample: VcSdJwt = decode(fromFile: "vc-sd-jwt-sample")
    static let samplePayload: VcSdJwtPayload = decode(fromFile: "vc-sd-jwt-sample-payload", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    static let reservedClaimsWithOneClaim: VcSdJwt = decode(fromFile: "vc-sd-jwt-reserved-claims-with-one-claim")
    static let noKeyBinding: VcSdJwt = decode(fromFile: "vc-sd-jwt-no-key-binding")
    static let allFieldsData: Data = getData(fromFile: "vc-sd-jwt-sample", ofType: "txt", bundle: Bundle.module) ?? Data()
  }

  struct ExpandedMock {
    static let validSample: Data = getData(fromFile: "vc-sd-jwt-sample-expanded-format-valid", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let sampleWithoutJwk: Data = getData(fromFile: "vc-sd-jwt-sample-expanded-format-no-jwk", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let sampleWithoutKeyDetails: Data = getData(fromFile: "vc-sd-jwt-sample-expanded-format-no-key-details", ofType: "txt", bundle: Bundle.module) ?? Data()
  }

  static func decode(fromFile filename: String, bundle: Bundle = Bundle.module) -> VcSdJwt {
    let data = getData(fromFile: filename, ofType: "txt", bundle: bundle) ?? Data()
    let decoder = SdJWSDecoder(dateDecodingStrategy: .secondsSince1970)
    return try! decoder.decode(VcSdJwtPayload.self, from: data)
  }
}
// swiftlint:enable all
#endif
