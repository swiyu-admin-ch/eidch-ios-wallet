import BITAnyCredentialFormat
import BITCore
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
  func generate(for anyCredential: AnyCredential, keyPair: VaultKeyPair?, rawOcaBundle: RawOcaBundle?, metadataWrapper: CredentialMetadataWrapper) throws -> VerifiableCredential
}

// MARK: - CredentialGenerator

struct CredentialGenerator: CredentialGeneratorProtocol {

  // MARK: Internal

  func generate(for anyCredential: AnyCredential, keyPair: VaultKeyPair?, rawOcaBundle: RawOcaBundle?, metadataWrapper: CredentialMetadataWrapper) throws -> VerifiableCredential {
    let id = UUID()
    let keyBinding = try createKeyBinding(from: keyPair)
    let issuerDisplays = createIssuerDisplays(from: metadataWrapper.credentialMetadata.display, credentialId: id)
    let ocaBundle = rawOcaBundle.flatMap { try? ocaBundler.createOcaBundle($0) }
    let rawCredentialData = RawCredentialData(rawOIDMetadata: metadataWrapper.rawData, rawOcaBundle: rawOcaBundle)
    return if let ocaBundle {
      try ocaCredentialGenerator.generate(for: anyCredential, id: id, keyBinding: keyBinding, ocaBundle: ocaBundle, issuerDisplays: issuerDisplays, rawCredentialData: rawCredentialData)
    } else {
      try metadataCredentialGenerator.generate(for: anyCredential, id: id, keyBinding: keyBinding, selectedCredential: metadataWrapper.selectedCredential, issuerDisplays: issuerDisplays, rawCredentialData: rawCredentialData)
    }
  }

  // MARK: Private

  @Injected(\.ocaBundler) private var ocaBundler: OcaBundlerProtocol
  @Injected(\.ocaCredentialGenerator) private var ocaCredentialGenerator: OcaCredentialGeneratorProtocol
  @Injected(\.metadataCredentialGenerator) private var metadataCredentialGenerator: MetadataCredentialGeneratorProtocol
  @Injected(\.keyManager) private var keyManager: KeyManagerProtocol

  private func createIssuerDisplays(from displays: [CredentialMetadata.CredentialMetadataDisplay]?, credentialId: UUID) -> [CredentialIssuerDisplay] {
    displays?.map { display in
      CredentialIssuerDisplay(
        locale: display.locale,
        name: display.name,
        credentialId: credentialId,
        image: display.logo?.url?.dataURLData)
    } ?? []
  }

  private func createKeyBinding(from keyPair: VaultKeyPair?) throws -> CredentialKeyBinding? {
    try keyPair.flatMap { keyPair in
      let isHardwareKey = keyPair.options?.contains(.secureEnclave) ?? false
      let (publicKey, privateKey): (Data?, Data?) = isHardwareKey
        ? (nil, nil)
        : try keyManager.getExternalRepresentation(of: keyPair.privateKey)

      return CredentialKeyBinding(
        id: UUID(uuidString: keyPair.identifier) ?? UUID(),
        algorithm: keyPair.algorithm.rawValue,
        bindingType: isHardwareKey ? .hardware : .software,
        publicKey: publicKey,
        privateKey: privateKey)
    }
  }
}
