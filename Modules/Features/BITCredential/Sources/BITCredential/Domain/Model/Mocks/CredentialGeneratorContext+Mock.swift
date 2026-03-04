#if DEBUG
import Foundation
@testable import BITCredentialShared
@testable import BITOca
@testable import BITTestingCore

extension CredentialGeneratorContext {
  struct Mock {
    static let sample = CredentialGeneratorContext(
      credentialId: UUID(),
      issuerUrl: "https://issuer",
      credentialConfigurationId: "elfa-sdjwt",
      keyBinding: CredentialKeyBinding(
        id: UUID(),
        algorithm: "ES512",
        bindingType: .hardware),
      issuerDisplays: [CredentialIssuerDisplay(
        id: UUID(),
        credentialId: nil,
        image: nil)],
      rawCredentialData: RawCredentialData())

    static let sampleWithoutKeyBinding = CredentialGeneratorContext(
      credentialId: UUID(),
      issuerUrl: "https://issuer",
      credentialConfigurationId: "elfa-sdjwt",
      keyBinding: nil,
      issuerDisplays: [CredentialIssuerDisplay(
        id: UUID(),
        credentialId: nil,
        image: nil)],
      rawCredentialData: RawCredentialData())
  }
}

#endif
