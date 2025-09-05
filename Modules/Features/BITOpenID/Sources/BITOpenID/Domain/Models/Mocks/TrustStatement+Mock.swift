#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT
@testable import BITSdJWT
@testable import BITTestingCore

// swiftlint:disable force_try force_cast force_unwrapping

extension TrustStatementPayload: Mockable {
  struct Mock {

    // MARK: Internal

    static let allFieldsRawSdJwt: String = getString(fromFile: "trust-statement-all-fields-sd-jwt", bundle: Bundle.module)
    static let allFields: TrustStatement = encodePayload(fromFile: "trust-statement-all-fields")

    static let validSample: TrustStatement = encodePayload(fromFile: "trust-statement-valid-sample")
    static let invalidVct: TrustStatement = encodePayload(fromFile: "trust-statement-invalid-vct")
    static let wrongSubject: TrustStatement = encodePayload(fromFile: "trust-statement-wrong-subject")
    static let wrongAlgorithm: TrustStatement = encodePayload(fromFile: "trust-statement-valid-sample", jwtAlgorithm: JWTAlgorithm.ES384)
    static let validSampleItalian: TrustStatement = encodePayload(fromFile: "trust-statement-valid-sample-italian")

    static func encodePayload(fromFile filename: String, jwtAlgorithm: JWTAlgorithm = JWTAlgorithm.ES256, bundle: Bundle = Bundle.module) -> TrustStatement {
      let trustStatement: TrustStatementPayload = decode(fromFile: filename, dateFormatter: .secondsSince1970, bundle: bundle)
      let payloadData = getData(fromFile: filename, ofType: "json", bundle: bundle)!
      let payload = try! JSONSerialization.jsonObject(with: payloadData) as! [String: Any]
      return createSdJWSMock(from: trustStatement, rawPayload: payload, jwtAlgorithm: jwtAlgorithm)
    }

    // MARK: Private

    private static func createSdJWSMock(from trustStatement: TrustStatementPayload, rawPayload: [String: Any] = [:], jwtAlgorithm: JWTAlgorithm = JWTAlgorithm.ES256) -> TrustStatement {
      let jws = JWS(payload: trustStatement, rawPayload: "rawJWSPayload", rawJWS: "rawJWS", header: JWSHeader(algorithm: jwtAlgorithm))
      return TrustStatement(jws: jws, payload: trustStatement, resolvedPayload: rawPayload, rawSdJWS: "rawSdJWS", disclosableClaims: [])
    }
  }
}
// swiftlint:enable all

#endif
