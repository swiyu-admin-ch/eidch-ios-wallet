import BITAnyCredentialFormat
import BITCredentialShared
import BITOca
import BITOpenID
import BITVault
import Factory
import Foundation
import Spyable

// MARK: - CredentialGeneratorProtocol

@Spyable
protocol CredentialGeneratorProtocol {
  func generate(
    for credentialsWithKeyBinding: [CredentialWithKeyBinding],
    rawOcaBundle: RawOcaBundle?,
    metadataWrapper: CredentialIssuerMetadataWrapper,
    trustStatement: IdentityTrustStatementJWT?,
    authentication: CredentialAuthentication) throws
    -> VerifiableCredential
  func generateDeferred(
    _ deferredCredentialContext: DeferredCredentialContext,
    keyBindings: [KeyBinding],
    rawOcaBundle: RawOcaBundle?,
    metadataWrapper: CredentialIssuerMetadataWrapper,
    authentication: CredentialAuthentication) throws
    -> DeferredCredential
}

// MARK: - CredentialGenerator

struct CredentialGenerator: CredentialGeneratorProtocol {

  // MARK: Internal

  func generate(
    for credentialsWithKeyBinding: [CredentialWithKeyBinding],
    rawOcaBundle: RawOcaBundle?,
    metadataWrapper: CredentialIssuerMetadataWrapper,
    trustStatement: IdentityTrustStatementJWT?,
    authentication: CredentialAuthentication) throws
    -> VerifiableCredential
  {
    let (context, ocaBundle) = try generateContext(
      rawOcaBundle: rawOcaBundle,
      metadataWrapper: metadataWrapper,
      trustStatement: trustStatement,
      authentication: authentication)

    if let ocaBundle {
      return try ocaCredentialGenerator.generate(for: credentialsWithKeyBinding, ocaBundle: ocaBundle, context: context)
    }
    return try metadataCredentialGenerator.generate(for: credentialsWithKeyBinding, selectedCredential: metadataWrapper.selectedCredential, context: context)
  }

  func generateDeferred(
    _ deferredCredentialContext: DeferredCredentialContext,
    keyBindings: [KeyBinding],
    rawOcaBundle: RawOcaBundle?,
    metadataWrapper: CredentialIssuerMetadataWrapper,
    authentication: CredentialAuthentication) throws
    -> DeferredCredential
  {
    let (context, ocaBundle) = try generateContext(
      rawOcaBundle: rawOcaBundle,
      metadataWrapper: metadataWrapper,
      trustStatement: nil,
      authentication: authentication)

    return if let ocaBundle {
      try ocaCredentialGenerator.generateDeferred(
        deferredCredentialContext,
        keyBindings: keyBindings,
        ocaBundle: ocaBundle,
        context: context)
    } else {
      try metadataCredentialGenerator.generateDeferred(
        deferredCredentialContext,
        keyBindings: keyBindings,
        selectedCredential: metadataWrapper.selectedCredential,
        context: context)
    }
  }

  // MARK: Private

  @Injected(\.ocaBundler) private var ocaBundler: OcaBundlerProtocol
  @Injected(\.ocaCredentialGenerator) private var ocaCredentialGenerator: OcaCredentialGeneratorProtocol
  @Injected(\.metadataCredentialGenerator) private var metadataCredentialGenerator: MetadataCredentialGeneratorProtocol

  private func generateContext(
    rawOcaBundle: RawOcaBundle?,
    metadataWrapper: CredentialIssuerMetadataWrapper,
    trustStatement: IdentityTrustStatementJWT?,
    authentication: CredentialAuthentication) throws
    -> (CredentialGeneratorContext, OcaBundle?)
  {
    let id = UUID()
    let issuerDisplays = createIssuerDisplays(from: metadataWrapper.credentialIssuerMetadata.display, credentialId: id, trustStatement: trustStatement)
    let ocaBundle = rawOcaBundle.flatMap { try? ocaBundler.createOcaBundle($0) }
    let rawCredentialData = RawCredentialData(rawOIDMetadata: metadataWrapper.rawData, rawOcaBundle: rawOcaBundle)
    let batchData = createBatchData(batchSize: metadataWrapper.credentialIssuerMetadata.batchCredentialIssuance?.batchSize)

    return (
      CredentialGeneratorContext(
        credentialId: id,
        issuerUrl: metadataWrapper.credentialIssuerMetadata.credentialIssuer,
        credentialConfigurationId: metadataWrapper.credentialConfigurationId,
        batchData: batchData,
        authentication: authentication,
        issuerDisplays: issuerDisplays,
        rawCredentialData: rawCredentialData),
      ocaBundle)
  }

  private func createBatchData(batchSize: Int?) -> BatchData? {
    guard let batchSize else {
      return nil
    }

    return BatchData(batchSize: batchSize)
  }

  private func createIssuerDisplays(
    from displays: [CredentialIssuerMetadata.Display]?,
    credentialId: UUID,
    trustStatement: IdentityTrustStatementJWT?)
    -> [CredentialIssuerDisplay]
  {
    guard let trustStatement else {
      return displays?.map { display in
        CredentialIssuerDisplay(
          locale: display.locale,
          name: display.name,
          credentialId: credentialId,
          image: display.logo?.url?.dataURLData)
      } ?? []
    }

    let metadataDisplays = displays ?? []
    let entityNames = trustStatement.entityNames
    return entityNames.keys
      .sorted()
      .map { locale in
        CredentialIssuerDisplay(
          locale: locale,
          name: entityNames[locale],
          credentialId: credentialId,
          image: displayImage(for: locale, in: metadataDisplays))
      }
  }

  private func displayImage(for locale: String, in displays: [CredentialIssuerMetadata.Display]) -> Data? {
    if let exactMatch = displays.first(where: { $0.locale == locale }) {
      return exactMatch.logo?.url?.dataURLData
    }

    let prefixMatch = displays.first { display in
      guard let displayLocale = display.locale else { return false }
      // we cannot know if the entity name locale or metadata locale is more precise
      return displayLocale.hasPrefix(locale) || locale.hasPrefix(displayLocale)
    }
    return prefixMatch?.logo?.url?.dataURLData
  }
}
