import BITJWT
import Factory
import Foundation
import Spyable

// MARK: - ValidateTrustStatementUseCaseProtocol

@Spyable
public protocol ValidateTrustStatementUseCaseProtocol {
  func execute(_ trustStatement: TrustStatement, for subject: String) async -> Bool
}

// MARK: - ValidateTrustStatementUseCase

struct ValidateTrustStatementUseCase: ValidateTrustStatementUseCaseProtocol {

  // MARK: Internal

  func execute(_ trustStatement: TrustStatement, for subject: String) async -> Bool {
    do {
      let issuer = trustStatement.payload.issuer
      guard
        isDidTrusted(issuer),
        trustStatement.payload.subject == subject,
        trustStatement.payload.expiredAt >= now,
        trustStatement.payload.activatedAt <= now.addingTimeInterval(dateBuffer),
        trustStatement.header.algorithm == JWTAlgorithm.ES256
      else { return false }

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
  @Injected(\.dateBuffer) private var dateBuffer: TimeInterval

  private var now: Date {
    Date()
  }

  private func isDidTrusted(_ did: String) -> Bool {
    trustRegistryRepository.getTrustedDids().contains(did)
  }

}
