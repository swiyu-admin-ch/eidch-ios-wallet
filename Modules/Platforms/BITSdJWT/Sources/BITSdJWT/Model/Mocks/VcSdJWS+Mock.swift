#if DEBUG
import Factory
import Foundation
@testable import BITCore
@testable import BITJWT

// swiftlint:disable force_try

extension VcSdJWS: Mockable {

  struct Mock {

    static let sample: VcSdJWS = decode(fromFile: "vc-sd-jwt-sample")
    static let sampleBusinessExpired: VcSdJWS = decode(fromFile: "vc-sd-jwt-sample-business-expired")
    static let sampleData = getData(fromFile: "vc-sd-jwt-sample", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let sampleLegacyTypeData = getData(fromFile: "vc-sd-jwt-sample-legacy-type", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let unregistedNonSelectivelyDisclosableClaimData = getData(fromFile: "vc-sd-jwt-unregistered-non-selectively-disclosable-claim", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let noKeyBinding: VcSdJWS = decode(fromFile: "vc-sd-jwt-no-key-binding")
    static let noKeyBindingData = getData(fromFile: "vc-sd-jwt-no-key-binding", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let vctMetadataUriData = getData(fromFile: "vc-sd-jwt-vct-metadata-uri", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let legacyCnfJwkStructure = getData(fromFile: "vc-sd-jwt-legacy-cnf-jwk-structure", ofType: "txt", bundle: Bundle.module) ?? Data()

    static func create(
      expiredAt: Date = Date().addingTimeInterval(.days(30)),
      expiryDate: String = "2099-12-31",
      activatedAt: Date? = nil,
      type: String = "dc+sd-jwt")
      -> VcSdJWS
    {
      let base = VcSdJWS.Mock.sample
      var resolvedJSON = base.resolvedJSON
      resolvedJSON["expiry_date"] = expiryDate
      var resolvedPayload = base.resolvedPayload
      resolvedPayload.expiredAt = expiredAt
      resolvedPayload.activatedAt = activatedAt
      let jws = JWS(
        payload: resolvedPayload,
        rawPayload: base.rawPayload,
        rawJWS: base.rawJWS,
        header: JWSHeader(
          algorithm: base.header.algorithm,
          type: type,
          keyIdentifier: base.header.keyIdentifier,
          jwk: base.header.jwk,
          profileVersion: base.header.profileVersion))
      return VcSdJWS(
        jws: jws,
        payload: resolvedPayload,
        resolvedJSON: resolvedJSON,
        rawSdJWS: base.rawSdJWS,
        digestAlgorithm: base.digestAlgorithm,
        disclosures: base.disclosures,
        rawKeyBinding: base.rawKeyBinding,
        keyIdentifierDid: base.keyIdentifierDid)
    }
  }

  static func decode(fromFile filename: String, bundle: Bundle = Bundle.module) -> VcSdJWS {
    let data = getData(fromFile: filename, ofType: "txt", bundle: bundle) ?? Data()
    let didResolverHelperSpy = DidResolverHelperProtocolSpy()
    didResolverHelperSpy.getDidFromReturnValue = "did:example:123"
    Container.shared.didResolverHelper.register { didResolverHelperSpy }
    let decoder = VcSdJWSDecoder()
    return try! decoder.decode(VcSdJwt.self, from: data)
  }
}
#endif
