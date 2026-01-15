import BITJWT
import BITSdJWT
import Factory
import Foundation

// MARK: - TrustStatementValidatorProtocol

public protocol TrustStatementValidatorProtocol {
  func validate(_ trustStatement: SdJWS<some TrustStatement & Decodable>, for subject: String) async -> Bool
}

// MARK: - TrustStatementValidator

struct TrustStatementValidator: TrustStatementValidatorProtocol {

  // MARK: Internal

  func validate(_ trustStatement: SdJWS<some TrustStatement & Decodable>, for subject: String) async -> Bool {
    guard
      let issuer = trustStatement.payload.issuer,
      trustStatement.resolvedPayload.subject == subject,
      trustStatement.header.algorithm == JWTAlgorithm.ES256,
      (try? await jwsValidator.validate(trustStatement)) != nil
    else { return false }
    return await tokenStatusListValidator.validate(trustStatement.payload.statusList, issuer: issuer) == .valid
  }

  // MARK: Private

  @Injected(\.jwsValidator) private var jwsValidator: JWSValidatorProtocol
  @Injected(\.tokenStatusListValidator) private var tokenStatusListValidator: AnyStatusCheckValidatorProtocol
}
