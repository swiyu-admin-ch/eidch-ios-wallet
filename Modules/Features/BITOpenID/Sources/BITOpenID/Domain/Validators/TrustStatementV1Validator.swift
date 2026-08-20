import BITJWT
import BITSdJWT
import Factory
import Foundation

// MARK: - TrustStatementV1ValidatorProtocol

public protocol TrustStatementV1ValidatorProtocol {
  func validate(_ trustStatement: SdJWS<some TrustStatementV1JWT & Decodable>, for subject: String) async -> Bool
}

// MARK: - TrustStatementV1Validator

struct TrustStatementV1Validator: TrustStatementV1ValidatorProtocol {

  // MARK: Internal

  func validate(_ trustStatement: SdJWS<some TrustStatementV1JWT & Decodable>, for subject: String) async -> Bool {
    guard
      trustStatement.resolvedPayload.subject == subject,
      supportedSignatureValidationAlgorithms.contains(trustStatement.header.algorithm),
      (try? await jwsValidator.validate(trustStatement)) != nil,
      let issuer = try? didResolverHelper.getDid(from: trustStatement.header.keyIdentifier)
    else { return false }
    return await tokenStatusListValidator.validate(trustStatement.payload.statusList, issuer: issuer) == .valid
  }

  // MARK: Private

  @Injected(\.jwsValidator) private var jwsValidator: JWSValidatorProtocol
  @Injected(\.didResolverHelper) private var didResolverHelper: DidResolverHelperProtocol
  @Injected(\.supportedSignatureValidationAlgorithms) private var supportedSignatureValidationAlgorithms: [JWTAlgorithm]
  @Injected(\.tokenStatusListValidator) private var tokenStatusListValidator: AnyStatusCheckValidatorProtocol
}
