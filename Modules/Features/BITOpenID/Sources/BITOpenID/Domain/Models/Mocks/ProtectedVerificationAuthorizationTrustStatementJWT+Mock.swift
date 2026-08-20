#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT

// MARK: ProtectedVerificationAuthorizationTrustStatementJWT.Mock

extension ProtectedVerificationAuthorizationTrustStatementJWT: Mockable {

  // MARK: Internal

  struct Mock {

    static let sample = createObject(payload: sampleJWT)

    static let sampleData: Data = Mocker.getData(fromFile: "protected-verification-trust-statement", bundle: Bundle.module) ?? Data()
    static let emptyAuthorizedFieldsData: Data = Mocker.getData(fromFile: "protected-verification-trust-statement-empty-authorized-fields", bundle: Bundle.module) ?? Data()

    private static let sampleJWT: ProtectedVerificationAuthorizationTrustStatementJWT = decode(
      fromFile: "protected-verification-trust-statement",
      dateFormatter: .secondsSince1970,
      bundle: Bundle.module)
  }

  // MARK: Private

  private static func createObject(payload: ProtectedVerificationAuthorizationTrustStatementJWT) -> ProtectedVerificationAuthorizationTrustStatement {
    JWS(
      payload: payload,
      rawPayload: "rawPayload",
      rawJWS: "rawJWS",
      header: JWSHeader(algorithm: JWTAlgorithm.ES256, keyIdentifier: "did:example:trust-issuer#key-1", profileVersion: "swiss-profile-trust:1.0.0"))
  }
}
#endif
