#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT
@testable import BITSdJWT
@testable import BITTestingCore

// swiftlint:disable force_try force_cast force_unwrapping

extension TrustStatementPayload: Mockable {
  struct Mock {

    static let allFieldsData: Data = getData(fromFile: "trust-statement-all-fields", ofType: "txt", bundle: Bundle.module) ?? Data()

    static let validSample: TrustStatement = encodePayload(fromFile: "trust-statement-valid-sample")
    static let validSamplePayload: TrustStatementPayload = decode(fromFile: "trust-statement-valid-sample", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    static let wrongSubject: TrustStatement = encodePayload(fromFile: "trust-statement-wrong-subject")
    static let wrongAlgorithm: TrustStatement = encodePayload(fromFile: "trust-statement-valid-sample", jwtAlgorithm: JWTAlgorithm.ES384)
    static let notYetValid: TrustStatement = encodePayload(fromFile: "trust-statement-not-yet-valid-sample")
    static let expired: TrustStatement = encodePayload(fromFile: "trust-statement-expired-sample")
    static let validSampleItalian: TrustStatement = encodePayload(fromFile: "trust-statement-valid-sample-italian")
    static let sampleWithoutNameOrLogo: TrustStatement = encodePayload(fromFile: "trust-statement-without-logo-name")
    static let sdJwtSample: String = getString(fromFile: "trust-statement-sd-jwt", bundle: Bundle.module)

    static func encodePayload(fromFile filename: String, jwtAlgorithm: JWTAlgorithm = JWTAlgorithm.ES256, bundle: Bundle = Bundle.module) -> TrustStatement {
      let trustStatement: TrustStatementPayload = decode(fromFile: filename, dateFormatter: .secondsSince1970, bundle: bundle)
      let payloadData = getData(fromFile: filename, ofType: "json", bundle: bundle)!
      let payload = try! JSONSerialization.jsonObject(with: payloadData) as! [String: Any]
      return createSdJWSMock(from: trustStatement, rawPayload: payload, jwtAlgorithm: jwtAlgorithm)
    }

    static func createSdJWSMock(from trustStatement: TrustStatementPayload, rawPayload: [String: Any] = [:], jwtAlgorithm: JWTAlgorithm = JWTAlgorithm.ES256) -> TrustStatement {
      SdJWS(payload: trustStatement, rawPayload: rawPayload, header: JWSHeader(algorithm: jwtAlgorithm), raw: "raw", rawJWS: "rawJWS", disclosableClaims: [])
    }
  }
}
// swiftlint:enable all

#endif
