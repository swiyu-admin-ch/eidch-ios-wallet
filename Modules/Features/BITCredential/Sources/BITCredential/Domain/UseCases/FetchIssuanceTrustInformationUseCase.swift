import BITAnyCredentialFormat
import BITCore
import BITCredentialShared
import BITNonCompliance
import BITOpenID
import Factory
import Foundation
import Spyable

// MARK: - FetchIssuanceTrustInformationUseCaseProtocol

@Spyable
public protocol FetchIssuanceTrustInformationUseCaseProtocol {
  func callAsFunction(for credential: VerifiableCredential) async throws -> (TrustInformation, ActorCompliance)
}

// MARK: - FetchIssuanceTrustInformationUseCase

struct FetchIssuanceTrustInformationUseCase: FetchIssuanceTrustInformationUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(for credential: VerifiableCredential) async throws -> (TrustInformation, ActorCompliance) {
    let bundleItem = try selectCredentialBundleItemUseCase(credential)
    let anyCredential = try createAnyCredentialUseCase.execute(from: bundleItem.payload, format: credential.format)
    var isIdentityTrusted = false

    if
      let rawMetadata = credential.rawCredentialData?.rawOIDMetadata,
      let metadataJWT = try? JSONDecoder(dateDecodingStrategy: .secondsSince1970).decode(CredentialIssuerMetadataJWT.self, from: rawMetadata),
      let idTS = metadataJWT.credentialIssuerMetadata.identityTrustStatement
    {
      try await trustStatementValidator.validate(idTS, for: anyCredential.issuer)
      isIdentityTrusted = true
    }

    #warning("TODO: remove fetch of trust information when trust 2.0 is enforced (TP 2.0)")
    let trustInformation = await trustInformationService.fetch(for: anyCredential.issuer, type: .issuance, vcSchemaId: anyCredential.vcSchemaId)
    let actorCompliance = await fetchActorCompliance(for: anyCredential.issuer)
    guard isIdentityTrusted else { return (trustInformation, actorCompliance) }
    return (TrustInformation(identity: .trusted, vcSchema: trustInformation.vcSchema), actorCompliance)
  }

  // MARK: Private

  @Injected(\.trustInformationService) private var trustInformationService
  @Injected(\.nonComplianceRepository) private var nonComplianceRepository
  @Injected(\.createAnyCredentialUseCase) private var createAnyCredentialUseCase
  @Injected(\.selectCredentialBundleItemUseCase) private var selectCredentialBundleItemUseCase
  @Injected(\.trustStatementValidator) private var trustStatementValidator

  private func fetchActorCompliance(for subjectDid: String) async -> ActorCompliance {
    (try? await nonComplianceRepository.fetchActorCompliance(for: subjectDid)) ?? .notCompliant(nil)
  }
}
