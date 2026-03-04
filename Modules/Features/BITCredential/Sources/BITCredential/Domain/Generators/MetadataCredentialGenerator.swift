import BITAnyCredentialFormat
import BITCore
import BITCredentialShared
import BITOpenID
import Factory
import Foundation
import Spyable

// MARK: - MetadataCredentialGeneratorProtocol

@Spyable
protocol MetadataCredentialGeneratorProtocol {
  func generate(for anyCredential: AnyCredential, selectedCredential: any CredentialMetadata.AnyCredentialConfigurationSupported, context: CredentialGeneratorContext) throws -> VerifiableCredential
  func generateDeferred(_ deferredCredentialContext: DeferredCredentialContext, selectedCredential: any CredentialMetadata.AnyCredentialConfigurationSupported, context: CredentialGeneratorContext) throws -> DeferredCredential
}

// MARK: - MetadataCredentialGenerator

struct MetadataCredentialGenerator: MetadataCredentialGeneratorProtocol {

  // MARK: Internal

  func generate(for anyCredential: AnyCredential, selectedCredential: any CredentialMetadata.AnyCredentialConfigurationSupported, context: CredentialGeneratorContext) throws -> VerifiableCredential {
    guard let payload = anyCredential.raw.data(using: .utf8) else {
      throw CredentialError.invalidPayload
    }
    let cluster = createCluster(from: anyCredential.claims, selectedCredential: selectedCredential)
    let credentialDisplays = createCredentialDisplays(from: selectedCredential.display, credentialId: context.credentialId)

    return VerifiableCredential(
      id: context.credentialId,
      progressionState: .unaccepted,
      payload: payload,
      status: .unknown,
      clusters: [cluster],
      format: anyCredential.format,
      issuerUrl: context.issuerUrl,
      selectedConfigurationId: context.credentialConfigurationId,
      issuer: anyCredential.issuer,
      keyBinding: context.keyBinding,
      rawCredentialData: context.rawCredentialData,
      issuerDisplays: context.issuerDisplays,
      displays: credentialDisplays,
      validFrom: anyCredential.validFrom,
      validUntil: anyCredential.validUntil)
  }

  func generateDeferred(_ deferredCredentialContext: DeferredCredentialContext, selectedCredential: any CredentialMetadata.AnyCredentialConfigurationSupported, context: CredentialGeneratorContext) throws -> DeferredCredential {
    let credentialDisplays = createCredentialDisplays(from: selectedCredential.display, credentialId: context.credentialId)

    return DeferredCredential(
      transactionId: deferredCredentialContext.transactionId,
      accessToken: deferredCredentialContext.accessToken,
      endpoint: deferredCredentialContext.endpoint,
      format: deferredCredentialContext.format,
      issuerUrl: context.issuerUrl,
      selectedConfigurationId: context.credentialConfigurationId,
      issuerDisplays: context.issuerDisplays,
      displays: credentialDisplays,
      keyBinding: context.keyBinding,
      rawCredentialData: context.rawCredentialData)
  }

  // MARK: Private

  private func createCluster(from anyClaims: [AnyClaim], selectedCredential: any CredentialMetadata.AnyCredentialConfigurationSupported) -> CredentialClaimCluster {
    let claims = anyClaims.map { anyClaim in
      let metadataClaim = selectedCredential.claims.first(where: { "$." + $0.key == anyClaim.key })
      return createClaim(from: anyClaim, metadataClaim: metadataClaim)
    }
    return CredentialClaimCluster(claims: claims)
  }

  private func createClaim(from anyClaim: AnyClaim, metadataClaim: CredentialMetadata.Claim?) -> CredentialClaim {
    CredentialClaim(
      key: anyClaim.key.replacing("$.", with: ""),
      value: anyClaim.value?.rawValue,
      valueType: metadataClaim?.valueType?.rawValue ?? ValueType.string.rawValue,
      order: metadataClaim?.order ?? Int(Int16.max),
      displays: createClaimDisplays(from: metadataClaim))
  }

  private func createClaimDisplays(from metadataClaim: CredentialMetadata.Claim?) -> [CredentialClaimDisplay] {
    metadataClaim?.display?.map { display in
      CredentialClaimDisplay(locale: display.locale, name: display.name)
    } ?? []
  }

  private func createCredentialDisplays(from displays: [CredentialMetadata.CredentialSupportedDisplay]?, credentialId: UUID) -> [CredentialDisplay] {
    displays?.map { display in
      CredentialDisplay(
        name: display.name,
        backgroundColor: display.backgroundColor,
        locale: display.locale ?? UserLocale.defaultLocaleIdentifier,
        logoAltText: display.logo?.altText,
        logoBase64: display.logo?.url?.dataURLData,
        summary: display.summary,
        credentialId: credentialId)
    } ?? []
  }
}
