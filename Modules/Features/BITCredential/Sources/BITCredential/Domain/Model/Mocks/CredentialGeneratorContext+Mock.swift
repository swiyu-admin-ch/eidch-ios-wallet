// swiftlint:disable force_unwrapping
#if DEBUG
import Foundation
@testable import BITCore
@testable import BITCredentialShared
@testable import BITOca

extension CredentialGeneratorContext {
  struct Mock {
    static let sample = CredentialGeneratorContext(
      credentialId: UUID(),
      issuerUrl: URL(string: "https://issuer")!,
      credentialConfigurationId: "elfa-sdjwt",
      batchData: nil,
      authentication: CredentialAuthentication(accessToken: "accessToken"),
      issuerDisplays: [CredentialIssuerDisplay(
        id: UUID(),
        credentialId: nil,
        image: nil)],
      rawCredentialData: RawCredentialData())
  }
}

#endif
