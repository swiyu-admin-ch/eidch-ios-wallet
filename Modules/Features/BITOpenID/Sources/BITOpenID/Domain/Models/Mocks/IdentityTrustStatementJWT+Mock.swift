#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT

extension IdentityTrustStatementJWT: Mockable {
  struct Mock {

    // MARK: Internal

    static let validSampleData = getData(fromFile: "identity-trust-statement-jwt-valid-sample", bundle: Bundle.module) ?? Data()
    static let wrongSubjectData = getData(fromFile: "identity-trust-statement-jwt-wrong-subject", bundle: Bundle.module) ?? Data()

    static let validSample: IdentityTrustStatement = createJWS(payload: validSamplePayload, rawPayloadData: validSampleData)
    static let wrongSubject: IdentityTrustStatement = createJWS(payload: wrongSubjectPayload, rawPayloadData: wrongSubjectData)
    static let wrongAlgorithm: IdentityTrustStatement = createJWS(header: JWSHeader(algorithm: JWTAlgorithm.ES384, keyIdentifier: keyIdentifier, profileVersion: profileVersion))
    static let missingProfileVersion: IdentityTrustStatement = createJWS(header: JWSHeader(algorithm: JWTAlgorithm.ES256, keyIdentifier: keyIdentifier))
    static let wrongProfileVersion: IdentityTrustStatement = createJWS(header: JWSHeader(algorithm: JWTAlgorithm.ES256, keyIdentifier: keyIdentifier, profileVersion: "other-profile:1"))

    static let validSamplePayload: IdentityTrustStatementJWT = decode(fromFile: "identity-trust-statement-jwt-valid-sample", dateFormatter: .secondsSince1970, bundle: Bundle.module)

    static func createJWS(
      payload: IdentityTrustStatementJWT = validSamplePayload,
      rawPayloadData: Data = validSampleData,
      header: JWSHeader = JWSHeader(algorithm: JWTAlgorithm.ES256, keyIdentifier: keyIdentifier, profileVersion: profileVersion))
      -> IdentityTrustStatement
    {
      JWS(
        payload: payload,
        rawPayload: String(data: rawPayloadData, encoding: .utf8) ?? "",
        rawJWS: "rawJWS",
        header: header)
    }

    // MARK: Private

    private static let keyIdentifier = "did:example:issuer#key-1"
    private static let profileVersion = "swiss-profile-trust:1.0"

    private static let wrongSubjectPayload: IdentityTrustStatementJWT = decode(fromFile: "identity-trust-statement-jwt-wrong-subject", dateFormatter: .secondsSince1970, bundle: Bundle.module)

  }
}
#endif
