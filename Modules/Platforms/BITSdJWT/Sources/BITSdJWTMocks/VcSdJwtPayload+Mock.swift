#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT
@testable import BITSdJWT
@testable import BITTestingCore

// swiftlint:disable force_try

extension VcSdJwtPayload: Mockable {

  struct Mock {

    static let sample: VcSdJwt = decode(fromFile: "vc-sd-jwt-sample")
    static let samplePayload: VcSdJwtPayload = decode(fromFile: "vc-sd-jwt-sample-payload", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    static let reservedClaimsWithOneClaim: VcSdJwt = decode(fromFile: "vc-sd-jwt-reserved-claims-with-one-claim")
    static let noKeyBinding: VcSdJwt = decode(fromFile: "vc-sd-jwt-no-key-binding")
    static let vctMetadataUri: VcSdJwt = decode(fromFile: "vc-sd-jwt-vct-metadata-uri")
  }

  static func decode(fromFile filename: String, bundle: Bundle = Bundle.module) -> VcSdJwt {
    let data = getData(fromFile: filename, ofType: "txt", bundle: bundle) ?? Data()
    let decoder = SdJWSDecoder(dateDecodingStrategy: .secondsSince1970)
    return try! decoder.decode(VcSdJwtPayload.self, from: data)
  }
}
#endif
