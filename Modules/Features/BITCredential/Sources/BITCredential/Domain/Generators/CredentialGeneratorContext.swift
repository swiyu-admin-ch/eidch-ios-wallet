import BITCredentialShared
import Foundation

struct CredentialGeneratorContext: Codable {
  let credentialId: UUID
  let issuerUrl: String
  let credentialConfigurationId: String
  let batchData: BatchData?
  let authentication: CredentialAuthentication
  let issuerDisplays: [CredentialIssuerDisplay]
  let rawCredentialData: RawCredentialData
}
