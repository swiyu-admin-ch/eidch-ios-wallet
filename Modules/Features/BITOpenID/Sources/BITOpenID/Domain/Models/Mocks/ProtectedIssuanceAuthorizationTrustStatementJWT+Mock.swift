#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT

// MARK: ProtectedIssuanceAuthorizationTrustStatementJWT.Mock

extension ProtectedIssuanceAuthorizationTrustStatementJWT: Mockable {
  struct Mock {

    // MARK: Internal

    static let rawJWS = "rawJWS"
    static let rawJWSData = Data(rawJWS.utf8)

    static let sample: ProtectedIssuanceAuthorizationTrustStatement = createObject(payload: sampleJWT)
    static let otherSubject: ProtectedIssuanceAuthorizationTrustStatement = createObject(payload: otherSubjectJWT)
    static let otherVct: ProtectedIssuanceAuthorizationTrustStatement = createObject(payload: otherVctJWT)

    static let sampleData: Data = Mocker.getData(
      fromFile: "protected-issuance-authorization-trust-statement",
      bundle: Bundle.module) ?? Data()

    // MARK: Private

    private static let sampleJWT: ProtectedIssuanceAuthorizationTrustStatementJWT = decode(
      fromFile: "protected-issuance-authorization-trust-statement",
      dateFormatter: .secondsSince1970,
      bundle: Bundle.module)

    private static let otherSubjectJWT: ProtectedIssuanceAuthorizationTrustStatementJWT = decode(
      fromFile: "protected-issuance-authorization-trust-statement-other-subject",
      dateFormatter: .secondsSince1970,
      bundle: Bundle.module)

    private static let otherVctJWT: ProtectedIssuanceAuthorizationTrustStatementJWT = decode(
      fromFile: "protected-issuance-authorization-trust-statement-other-vct",
      dateFormatter: .secondsSince1970,
      bundle: Bundle.module)

    private static func createObject(payload: ProtectedIssuanceAuthorizationTrustStatementJWT) -> ProtectedIssuanceAuthorizationTrustStatement {
      JWS(
        payload: payload,
        rawPayload: "rawPayload",
        rawJWS: rawJWS,
        header: JWSHeader(algorithm: JWTAlgorithm.ES256, keyIdentifier: "did:example:trust-issuer#key-1", profileVersion: "swiss-profile-trust:1.0.0"))
    }
  }
}
#endif
