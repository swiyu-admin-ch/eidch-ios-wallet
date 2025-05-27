import BITAnyCredentialFormat
import BITCore
import BITCredentialShared
import BITCrypto
import BITOca
import BITOpenID
import Factory
import Foundation
import Spyable

// MARK: - CredentialGeneratorProtocol

@Spyable
protocol CredentialGeneratorProtocol {
  func generate(for anyCredential: AnyCredential, keyPair: KeyPair?, ocaBundle: OcaBundle?, metadataWrapper: CredentialMetadataWrapper) throws -> Credential
}

// MARK: - CredentialGenerator

struct CredentialGenerator: CredentialGeneratorProtocol {

  // MARK: Internal

  func generate(for anyCredential: AnyCredential, keyPair: KeyPair?, ocaBundle: OcaBundle?, metadataWrapper: CredentialMetadataWrapper) throws -> Credential {
    let id = UUID()
    let issuerDisplays = createIssuerDisplays(from: metadataWrapper.credentialMetadata.display, credentialId: id)
    return if let ocaBundle {
      try ocaCredentialGenerator.generate(for: anyCredential, id: id, keyPair: keyPair, ocaBundle: ocaBundle, issuerDisplays: issuerDisplays)
    } else {
      try metadataCredentialGenerator.generate(for: anyCredential, id: id, keyPair: keyPair, selectedCredential: metadataWrapper.selectedCredential, issuerDisplays: issuerDisplays)
    }
  }

  // MARK: Private

  @Injected(\.ocaCredentialGenerator) private var ocaCredentialGenerator: OcaCredentialGeneratorProtocol
  @Injected(\.metadataCredentialGenerator) private var metadataCredentialGenerator: MetadataCredentialGeneratorProtocol

  private func createIssuerDisplays(from displays: [CredentialMetadata.CredentialMetadataDisplay]?, credentialId: UUID) -> [CredentialIssuerDisplay] {
    displays?.map { display in
      CredentialIssuerDisplay(
        locale: display.locale,
        name: display.name,
        credentialId: credentialId,
        image: display.logo?.uri.flatMap { Data(base64Encoded: $0) })
    } ?? []
  }
}
