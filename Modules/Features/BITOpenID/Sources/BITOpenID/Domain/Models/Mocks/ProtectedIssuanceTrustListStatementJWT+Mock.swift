#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT

// MARK: ProtectedIssuanceTrustListStatementJWT.Mock

extension ProtectedIssuanceTrustListStatementJWT: Mockable {
  struct Mock {

    // MARK: Internal

    static let rawJWS = "rawJWS"
    static let rawJWSData = Data(rawJWS.utf8)

    static let sample: ProtectedIssuanceTrustListStatement = createObject(payload: sampleJWT)
    static let unprotected: ProtectedIssuanceTrustListStatement = createObject(payload: unprotectedJWT)

    static let sampleData: Data = Mocker.getData(
      fromFile: "protected-issuance-trust-list-statement",
      bundle: Bundle.module) ?? Data()

    // MARK: Private

    private static let sampleJWT: ProtectedIssuanceTrustListStatementJWT = decode(
      fromFile: "protected-issuance-trust-list-statement",
      dateFormatter: .secondsSince1970,
      bundle: Bundle.module)

    private static let unprotectedJWT: ProtectedIssuanceTrustListStatementJWT = decode(
      fromFile: "protected-issuance-trust-list-statement-unprotected",
      dateFormatter: .secondsSince1970,
      bundle: Bundle.module)

    private static func createObject(payload: ProtectedIssuanceTrustListStatementJWT) -> ProtectedIssuanceTrustListStatement {
      JWS(
        payload: payload,
        rawPayload: "rawPayload",
        rawJWS: rawJWS,
        header: JWSHeader(algorithm: JWTAlgorithm.ES256, keyIdentifier: "did:example:trust-issuer#key-1", profileVersion: "swiss-profile-trust:1.0.0"))
    }
  }
}
#endif
