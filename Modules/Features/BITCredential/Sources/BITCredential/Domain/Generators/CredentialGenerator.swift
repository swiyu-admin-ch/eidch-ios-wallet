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
  func generate(for anyCredential: AnyCredential, keyBinding: CredentialKeyBinding?, rawOcaBundle: RawOcaBundle?, metadataWrapper: CredentialMetadataWrapper) throws -> VerifiableCredential
  func generateDeferred(_ deferredCredentialRequest: DeferredCredentialRequest, keyBinding: CredentialKeyBinding?, rawOcaBundle: RawOcaBundle?, metadataWrapper: CredentialMetadataWrapper) throws -> DeferredCredential
}

// MARK: - CredentialGenerator

struct CredentialGenerator: CredentialGeneratorProtocol {

  // MARK: Internal

  func generate(for anyCredential: AnyCredential, keyBinding: CredentialKeyBinding?, rawOcaBundle: RawOcaBundle?, metadataWrapper: CredentialMetadataWrapper) throws -> VerifiableCredential {
    let (context, ocaBundle) = try generate(keyBinding: keyBinding, rawOcaBundle: rawOcaBundle, metadataWrapper: metadataWrapper)

    return if let ocaBundle {
      try ocaCredentialGenerator.generate(for: anyCredential, ocaBundle: ocaBundle, context: context)
    } else {
      try metadataCredentialGenerator.generate(for: anyCredential, selectedCredential: metadataWrapper.selectedCredential, context: context)
    }
  }

  func generateDeferred(_ deferredCredentialRequest: DeferredCredentialRequest, keyBinding: CredentialKeyBinding?, rawOcaBundle: RawOcaBundle?, metadataWrapper: CredentialMetadataWrapper) throws -> DeferredCredential {
    let (context, ocaBundle) = try generate(keyBinding: keyBinding, rawOcaBundle: rawOcaBundle, metadataWrapper: metadataWrapper)

    return if let ocaBundle {
      try ocaCredentialGenerator.generateDeferred(deferredCredentialRequest, ocaBundle: ocaBundle, context: context)
    } else {
      try metadataCredentialGenerator.generateDeferred(deferredCredentialRequest, selectedCredential: metadataWrapper.selectedCredential, context: context)
    }
  }

  // MARK: Private

  @Injected(\.ocaBundler) private var ocaBundler: OcaBundlerProtocol
  @Injected(\.ocaCredentialGenerator) private var ocaCredentialGenerator: OcaCredentialGeneratorProtocol
  @Injected(\.metadataCredentialGenerator) private var metadataCredentialGenerator: MetadataCredentialGeneratorProtocol

  private func generate(keyBinding: CredentialKeyBinding?, rawOcaBundle: RawOcaBundle?, metadataWrapper: CredentialMetadataWrapper) throws -> (CredentialGeneratorContext, OcaBundle?) {
    let id = UUID()
    let issuerDisplays = createIssuerDisplays(from: metadataWrapper.credentialMetadata.display, credentialId: id)
    let ocaBundle = rawOcaBundle.flatMap { try? ocaBundler.createOcaBundle($0) }
    let rawCredentialData = RawCredentialData(rawOIDMetadata: metadataWrapper.rawData, rawOcaBundle: rawOcaBundle)

    return (CredentialGeneratorContext(credentialId: id, credentialConfigurationId: metadataWrapper.credentialConfigurationId, keyBinding: keyBinding, issuerDisplays: issuerDisplays, rawCredentialData: rawCredentialData), ocaBundle)
  }

  private func createIssuerDisplays(from displays: [CredentialMetadata.CredentialMetadataDisplay]?, credentialId: UUID) -> [CredentialIssuerDisplay] {
    displays?.map { display in
      CredentialIssuerDisplay(
        locale: display.locale,
        name: display.name,
        credentialId: credentialId,
        image: display.logo?.url?.dataURLData)
    } ?? []
  }
}
