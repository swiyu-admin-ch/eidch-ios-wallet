import BITAnalytics
import BITJWT
import Factory
import Spyable

// MARK: - ActorIdentityValidatorProtocol

@Spyable
public protocol ActorIdentityValidatorProtocol {
  func validate(_ metadataJws: JWS<CredentialIssuerMetadataJWT>) async throws
  func validate(_ identityTrustStatement: IdentityTrustStatement?, for actorDid: String) async throws
  func validate(issuerDid: String, metadataJws: JWS<CredentialIssuerMetadataJWT>) throws
}

// MARK: - ActorIdentityValidator

struct ActorIdentityValidator: ActorIdentityValidatorProtocol {

  // MARK: Internal

  func validate(_ metadataJws: JWS<CredentialIssuerMetadataJWT>) async throws {
    let actorDid = try didResolverHelper.getDid(from: metadataJws.header.keyIdentifier)
    guard let identityTrustStatement = metadataJws.payload.credentialIssuerMetadata.identityTrustStatement
    else {
      #warning("checks TP 1.0 identity, remove as soon as TP 2.0 is enforced")
      if isActorIdentityValidationEnabled {
        do {
          _ = try await trustStatementService.fetchIdentity(for: actorDid)
        } catch {
          let error = GovernanceError.unverifiedActor
          analytics.log(error)
          throw error
        }
      }
      return
    }
    try await validate(identityTrustStatement, for: actorDid)
  }

  func validate(_ identityTrustStatement: IdentityTrustStatement?, for actorDid: String) async throws {
    guard let identityTrustStatement else { return }
    do {
      guard TrustEnvironment(did: actorDid) != .external else {
        throw GovernanceError.unknownRegistry
      }
      try await trustStatementValidator.validate(identityTrustStatement, for: actorDid)
    } catch {
      let error = error as? GovernanceError ?? GovernanceError.unverifiedActor
      analytics.log(error)
      throw error
    }
  }

  func validate(issuerDid: String, metadataJws: JWS<CredentialIssuerMetadataJWT>) throws {
    guard isActorIdentityValidationEnabled else { return }
    let metadataDid = try didResolverHelper.getDid(from: metadataJws.header.keyIdentifier)
    guard issuerDid == metadataDid else {
      let error = GovernanceError.unverifiedActor
      analytics.log(error)
      throw error
    }
  }

  // MARK: Private

  @Injected(\.trustStatementValidator) private var trustStatementValidator
  @Injected(\.didResolverHelper) private var didResolverHelper
  @Injected(\.trustStatementService) private var trustStatementService
  @Injected(\.isActorIdentityValidationEnabled) private var isActorIdentityValidationEnabled
  @Injected(\.analytics) private var analytics: AnalyticsProtocol
}
