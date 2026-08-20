#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT
@testable import BITSdJWT

// swiftlint:disable force_try force_cast force_unwrapping

extension IdentityTrustStatementV1JWT: Mockable {
  struct Mock {

    // MARK: Internal

    static let allFields: IdentityTrustStatementV1 = encodePayload(fromFile: "identity-trust-statement-all-fields")

    static let validSample: IdentityTrustStatementV1 = encodePayload(fromFile: "identity-trust-statement-valid-sample")
    static let invalidVct: IdentityTrustStatementV1 = encodePayload(fromFile: "identity-trust-statement-invalid-vct")
    static let wrongSubject: IdentityTrustStatementV1 = encodePayload(fromFile: "identity-trust-statement-wrong-subject")
    static let wrongAlgorithm: IdentityTrustStatementV1 = encodePayload(fromFile: "identity-trust-statement-valid-sample", jwtAlgorithm: JWTAlgorithm.ES384)
    static let validSampleItalian: IdentityTrustStatementV1 = encodePayload(fromFile: "identity-trust-statement-valid-sample-italian")
    static let localeVariants: IdentityTrustStatementV1 = encodePayload(fromFile: "identity-trust-statement-locale-variants")

    static func encodePayload(fromFile filename: String, jwtAlgorithm: JWTAlgorithm = JWTAlgorithm.ES256, bundle: Bundle = Bundle.module) -> IdentityTrustStatementV1 {
      let trustStatement: IdentityTrustStatementV1JWT = decode(fromFile: filename, dateFormatter: .secondsSince1970, bundle: bundle)
      let payloadData = getData(fromFile: filename, ofType: "json", bundle: bundle)!
      let payload = try! JSONSerialization.jsonObject(with: payloadData) as! [String: Any]
      return createSdJWSMock(from: trustStatement, rawPayload: payload, jwtAlgorithm: jwtAlgorithm)
    }

    // MARK: Private

    private static func createSdJWSMock(from trustStatement: IdentityTrustStatementV1JWT, rawPayload: [String: Any] = [:], jwtAlgorithm: JWTAlgorithm = JWTAlgorithm.ES256) -> IdentityTrustStatementV1 {
      let jws = JWS(payload: trustStatement, rawPayload: "rawJWSPayload", rawJWS: "rawJWS", header: JWSHeader(algorithm: jwtAlgorithm))
      return IdentityTrustStatementV1(jws: jws, payload: trustStatement, resolvedJSON: rawPayload, rawSdJWS: "rawSdJWS", disclosures: [], rawKeyBinding: nil, keyIdentifierDid: "did:tdw:example")
    }
  }
}
// swiftlint:enable all

#endif
