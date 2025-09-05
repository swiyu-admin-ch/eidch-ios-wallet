import BITJWT
import Factory
import Foundation
import Spyable

// MARK: - TrustStatementValidatorProtocol

@Spyable
public protocol TrustStatementValidatorProtocol {
  func validate(_ trustStatement: TrustStatement, for subject: String) async -> Bool
}

// MARK: - TrustStatementValidator

struct TrustStatementValidator: TrustStatementValidatorProtocol {

  // MARK: Internal

  func validate(_ trustStatement: TrustStatement, for subject: String) async -> Bool {
    let issuer = trustStatement.payload.issuer
    guard
      trustStatement.payload.vct == Self.vctV1,
      trustStatement.resolvedPayload.subject == subject,
      isDidTrusted(issuer),
      trustStatement.header.algorithm == JWTAlgorithm.ES256,
      (try? await jwsValidator.validate(trustStatement, issuerDid: issuer)) == true
    else { return false }
    return await tokenStatusListValidator.validate(trustStatement.payload.statusList, issuer: issuer) == .valid
  }

  // MARK: Private

  private static let vctV1 = "TrustStatementIdentityV1"

  @Injected(\.jwsValidator) private var jwsValidator: JWSValidatorProtocol
  @Injected(\.trustRegistryRepository) private var trustRegistryRepository: TrustRegistryRepositoryProtocol
  @Injected(\.tokenStatusListValidator) private var tokenStatusListValidator: AnyStatusCheckValidatorProtocol

  private func isDidTrusted(_ did: String) -> Bool {
    trustRegistryRepository.getTrustedDids().contains(did)
  }
}
