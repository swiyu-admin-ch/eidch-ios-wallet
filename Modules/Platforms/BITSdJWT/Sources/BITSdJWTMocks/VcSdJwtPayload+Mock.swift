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
    static let noKeyBinding: VcSdJwt = decode(fromFile: "vc-sd-jwt-no-key-binding")
    static let allFieldsData: Data = getData(fromFile: "vc-sd-jwt-all-fields", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let requiredFieldsData: Data = getData(fromFile: "vc-sd-jwt-required-fields", ofType: "txt", bundle: Bundle.module) ?? Data()
  }

  static func decode(fromFile filename: String, bundle: Bundle = Bundle.module) -> VcSdJwt {
    let data = getData(fromFile: filename, ofType: "txt", bundle: bundle) ?? Data()
    let decoder = SdJWSDecoder(dateDecodingStrategy: .secondsSince1970)
    return try! decoder.decode(VcSdJwtPayload.self, from: data)
  }
}
// swiftlint:enable all
#endif
