import BITCredentialShared
import BITOca
import Foundation

struct CredentialGeneratorContext: Codable {
  let credentialId: UUID
  let selectedCredentialSupportedId: String
  let keyBinding: CredentialKeyBinding?
  let issuerDisplays: [CredentialIssuerDisplay]
  let rawCredentialData: RawCredentialData
}
