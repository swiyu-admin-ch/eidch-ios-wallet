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
    for anyCredential: AnyCredential,
    keyBinding: CredentialKeyBinding?,
    rawOcaBundle: RawOcaBundle?,
    metadataWrapper: CredentialMetadataWrapper,
    trustStatement: IdentityTrustStatementJWT?) throws
    -> VerifiableCredential
  func generateDeferred(
    _ deferredCredentialContext: DeferredCredentialContext,
    keyBinding: CredentialKeyBinding?,
    rawOcaBundle: RawOcaBundle?,
    metadataWrapper: CredentialMetadataWrapper) throws
    -> DeferredCredential
}

// MARK: - CredentialGenerator

struct CredentialGenerator: CredentialGeneratorProtocol {

  // MARK: Internal

  func generate(
    for anyCredential: AnyCredential,
    keyBinding: CredentialKeyBinding?,
    rawOcaBundle: RawOcaBundle?,
    metadataWrapper: CredentialMetadataWrapper,
    trustStatement: IdentityTrustStatementJWT?) throws
    -> VerifiableCredential
  {
    let (context, ocaBundle) = try generateContext(keyBinding: keyBinding, rawOcaBundle: rawOcaBundle, metadataWrapper: metadataWrapper, trustStatement: trustStatement)

    return if let ocaBundle {
      try ocaCredentialGenerator.generate(for: anyCredential, ocaBundle: ocaBundle, context: context)
    } else {
      try metadataCredentialGenerator.generate(for: anyCredential, selectedCredential: metadataWrapper.selectedCredential, context: context)
    }
  }

  func generateDeferred(
    _ deferredCredentialContext: DeferredCredentialContext,
    keyBinding: CredentialKeyBinding?,
    rawOcaBundle: RawOcaBundle?,
    metadataWrapper: CredentialMetadataWrapper) throws
    -> DeferredCredential
  {
    let (context, ocaBundle) = try generateContext(
      keyBinding: keyBinding,
      rawOcaBundle: rawOcaBundle,
      metadataWrapper: metadataWrapper,
      trustStatement: nil)

    return if let ocaBundle {
      try ocaCredentialGenerator.generateDeferred(deferredCredentialContext, ocaBundle: ocaBundle, context: context)
    } else {
      try metadataCredentialGenerator.generateDeferred(deferredCredentialContext, selectedCredential: metadataWrapper.selectedCredential, context: context)
    }
  }

  // MARK: Private

  @Injected(\.ocaBundler) private var ocaBundler: OcaBundlerProtocol
  @Injected(\.ocaCredentialGenerator) private var ocaCredentialGenerator: OcaCredentialGeneratorProtocol
  @Injected(\.metadataCredentialGenerator) private var metadataCredentialGenerator: MetadataCredentialGeneratorProtocol

  private func generateContext(
    keyBinding: CredentialKeyBinding?,
    rawOcaBundle: RawOcaBundle?,
    metadataWrapper: CredentialMetadataWrapper,
    trustStatement: IdentityTrustStatementJWT?) throws
    -> (CredentialGeneratorContext, OcaBundle?)
  {
    let id = UUID()
    let issuerDisplays = createIssuerDisplays(from: metadataWrapper.credentialMetadata.display, credentialId: id, trustStatement: trustStatement)
    let ocaBundle = rawOcaBundle.flatMap { try? ocaBundler.createOcaBundle($0) }
    let rawCredentialData = RawCredentialData(rawOIDMetadata: metadataWrapper.rawData, rawOcaBundle: rawOcaBundle)

    return (
      CredentialGeneratorContext(
        credentialId: id,
        issuerUrl: metadataWrapper.credentialMetadata.credentialIssuer,
        credentialConfigurationId: metadataWrapper.credentialConfigurationId,
        keyBinding: keyBinding,
        issuerDisplays: issuerDisplays,
        rawCredentialData: rawCredentialData),
      ocaBundle)
  }

  private func createIssuerDisplays(
    from displays: [CredentialMetadata.CredentialMetadataDisplay]?,
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

  private func displayImage(for locale: String, in displays: [CredentialMetadata.CredentialMetadataDisplay]) -> Data? {
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
