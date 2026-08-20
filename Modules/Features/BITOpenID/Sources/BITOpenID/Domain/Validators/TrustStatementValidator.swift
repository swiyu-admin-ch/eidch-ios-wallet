import BITJWT
import Factory
import Foundation

// MARK: - TrustStatementValidatorProtocol

public protocol TrustStatementValidatorProtocol {
  func validate(_ trustStatement: JWS<some TrustStatementJWT>) async throws
  func validate(_ trustStatement: JWS<some TrustStatementJWT>, for subjectDid: String?) async throws
}

extension TrustStatementValidatorProtocol {
  func validate(_ trustStatement: JWS<some TrustStatementJWT>) async throws {
    try await validate(trustStatement, for: nil)
  }
}

// MARK: - TrustStatementValidator

struct TrustStatementValidator: TrustStatementValidatorProtocol {

  // MARK: Internal

  func validate(_ statement: JWS<some TrustStatementJWT>, for subjectDid: String?) async throws {
    guard
      statement.header.profileVersion?.hasPrefix(profileVersionPrefix) == true,
      supportedSignatureValidationAlgorithms.contains(statement.header.algorithm)
    else {
      throw TrustStatementServiceError.validationFailed
    }

    if let subjectDid, subjectDid != statement.payload.subject {
      throw TrustStatementServiceError.validationFailed
    }

    try await jwsValidator.validate(statement)
    let issuer = try didResolverHelper.getDid(from: statement.header.keyIdentifier)
    let trustRegistryURL = try trustRegistryUrlMapper.map(did: issuer)
    guard isTrustedDid(issuer, for: statement.payload.type, from: trustRegistryURL) else {
      throw TrustStatementServiceError.validationFailed
    }
    if let status = statement.payload.status {
      guard await tokenStatusListValidator.validate(status, issuer: issuer) == .valid else {
        throw TrustStatementServiceError.validationFailed
      }
    }
  }

  // MARK: Private

  private let profileVersionPrefix = "swiss-profile-trust:"

  @Injected(\.jwsValidator) private var jwsValidator: JWSValidatorProtocol
  @Injected(\.didResolverHelper) private var didResolverHelper: DidResolverHelperProtocol
  @Injected(\.supportedSignatureValidationAlgorithms) private var supportedSignatureValidationAlgorithms: [JWTAlgorithm]
  @Injected(\.tokenStatusListValidator) private var tokenStatusListValidator: AnyStatusCheckValidatorProtocol
  @Injected(\.trustRegistryTrustedDids) private var trustedDids: TrustRegistryTrustedDids
  @Injected(\.trustRegistryUrlMapper) private var trustRegistryUrlMapper: TrustRegistryUrlMapperProtocol

  private func isTrustedDid(_ did: String, for trustStatementType: String?, from trustRegistryURL: URL) -> Bool {
    guard let trustStatementType, let trustRegistryHost = trustRegistryURL.host() else { return false }
    return trustedDids[trustRegistryHost]?[trustStatementType]?.contains(did) == true
  }
}
