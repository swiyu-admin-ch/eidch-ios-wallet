import BITCrypto
import BITVault
import Foundation
import Security

// MARK: - CredentialRequest

/// The Credential Request object as defined in the OID4VCI specification
/// https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0.html#name-credential-request
public struct CredentialRequest: Codable {

  let credentialConfigurationId: String
  let proofs: Proofs?
  let credentialResponseEncryption: CredentialResponseEncryption?

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case credentialConfigurationId = "credential_configuration_id"
    case proofs
    case credentialResponseEncryption = "credential_response_encryption"
  }
}

// MARK: CredentialRequest.Proofs

extension CredentialRequest {
  struct Proofs: Codable {
    let jwt: [String]
  }
}
