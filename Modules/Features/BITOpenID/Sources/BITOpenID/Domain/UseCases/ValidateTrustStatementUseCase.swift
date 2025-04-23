import BITJWT
import Factory
import Foundation

// MARK: - ValidateTrustStatementUseCase

struct ValidateTrustStatementUseCase: ValidateTrustStatementUseCaseProtocol {

  // MARK: Internal

  func execute(_ trustStatement: TrustStatement) async -> Bool {
    do {
      let issuer = trustStatement.payload.issuer
      guard try isDidTrusted(issuer) else { return false }

      if try await jwsSignatureValidator.validate(trustStatement, did: issuer) {
        return await tokenStatusListValidator.validate(trustStatement.payload.statusList, issuer: issuer) == .valid
      }
    } catch {
      // treat errors as invalid
    }
    return false
  }

  // MARK: Private

  @Injected(\.jwsSignatureValidator) private var jwsSignatureValidator: JWSSignatureValidatorProtocol
  @Injected(\.trustRegistryRepository) private var trustRegistryRepository: TrustRegistryRepositoryProtocol
  @Injected(\.tokenStatusListValidator) private var tokenStatusListValidator: AnyStatusCheckValidatorProtocol

  private func isDidTrusted(_ did: String) throws -> Bool {
    try trustRegistryRepository.getTrustedDids().contains(did)
  }

}
