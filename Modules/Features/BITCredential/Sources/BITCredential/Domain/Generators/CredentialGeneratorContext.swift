import BITCredentialShared
import Foundation

struct CredentialGeneratorContext: Codable {
  let credentialId: UUID
  let issuerUrl: String
  let credentialConfigurationId: String
  let keyBinding: CredentialKeyBinding?
  let issuerDisplays: [CredentialIssuerDisplay]
  let rawCredentialData: RawCredentialData
}
