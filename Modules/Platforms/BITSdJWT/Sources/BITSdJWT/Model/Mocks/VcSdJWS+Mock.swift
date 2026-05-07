#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT

// swiftlint:disable force_try

extension VcSdJWS: Mockable {

  struct Mock {

    static let sample: VcSdJWS = decode(fromFile: "vc-sd-jwt-sample")
    static let sampleData = getData(fromFile: "vc-sd-jwt-sample", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let sampleJWT: VcSdJwt = decode(fromFile: "vc-sd-jwt-sample-payload", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    static let sampleLegacyTypeData = getData(fromFile: "vc-sd-jwt-sample-legacy-type", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let unregistedNonSelectivelyDisclosableClaimData = getData(fromFile: "vc-sd-jwt-unregistered-non-selectively-disclosable-claim", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let noKeyBinding: VcSdJWS = decode(fromFile: "vc-sd-jwt-no-key-binding")
    static let noKeyBindingData = getData(fromFile: "vc-sd-jwt-no-key-binding", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let vctMetadataUriData = getData(fromFile: "vc-sd-jwt-vct-metadata-uri", ofType: "txt", bundle: Bundle.module) ?? Data()
  }

  static func decode(fromFile filename: String, bundle: Bundle = Bundle.module) -> VcSdJWS {
    let data = getData(fromFile: filename, ofType: "txt", bundle: bundle) ?? Data()
    let decoder = VcSdJWSDecoder()
    return try! decoder.decode(VcSdJwt.self, from: data)
  }
}
#endif
