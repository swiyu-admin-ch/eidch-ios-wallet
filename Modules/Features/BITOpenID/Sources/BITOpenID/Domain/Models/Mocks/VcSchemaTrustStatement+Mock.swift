#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT
@testable import BITSdJWT

// swiftlint:disable force_try force_cast force_unwrapping

extension VcSchemaTrustStatementJWT: Mockable {
  struct Mock {

    // MARK: Internal

    static let issuanceRawSdJwtData: Data = getData(fromFile: "issuance-trust-statement-valid-sd-jwt", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let verificationRawSdJwtData: Data = getData(fromFile: "verification-trust-statement-valid-sd-jwt", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let validSample: VcSchemaTrustStatement = encodePayload(fromFile: "issuance-trust-statement-valid")
    static let validOtherSample: VcSchemaTrustStatement = encodePayload(fromFile: "issuance-trust-statement-other-valid")

    static let invalidVct: VcSchemaTrustStatement = encodePayload(fromFile: "issuance-trust-statement-invalid-vct")

    static func encodePayload(fromFile filename: String, jwtAlgorithm: JWTAlgorithm = JWTAlgorithm.ES256, bundle: Bundle = Bundle.module) -> VcSchemaTrustStatement {
      let trustStatement: VcSchemaTrustStatementJWT = decode(fromFile: filename, dateFormatter: .secondsSince1970, bundle: bundle)
      let payloadData = getData(fromFile: filename, ofType: "json", bundle: bundle)!
      let payload = try! JSONSerialization.jsonObject(with: payloadData) as! [String: Any]
      return createSdJWSMock(from: trustStatement, rawPayload: payload, jwtAlgorithm: jwtAlgorithm)
    }

    // MARK: Private

    private static func createSdJWSMock(from trustStatement: VcSchemaTrustStatementJWT, rawPayload: [String: Any] = [:], jwtAlgorithm: JWTAlgorithm = JWTAlgorithm.ES256) -> VcSchemaTrustStatement {
      let jws = JWS(payload: trustStatement, rawPayload: "rawJWSPayload", rawJWS: "rawJWS", header: JWSHeader(algorithm: jwtAlgorithm))
      return VcSchemaTrustStatement(jws: jws, payload: trustStatement, resolvedJSON: rawPayload, rawSdJWS: "rawSdJWS", disclosureMap: [:], disclosableClaims: [])
    }
  }
}
// swiftlint:enable all

#endif
