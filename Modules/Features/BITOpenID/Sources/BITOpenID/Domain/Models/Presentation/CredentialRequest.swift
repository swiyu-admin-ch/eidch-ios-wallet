import Foundation

// MARK: - CredentialRequest

/// The Credential Request object as defined in the OID4VCI specification
/// https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0.html#name-credential-request
public struct CredentialRequest: Codable {

  let credentialConfigurationId: String
  let proofs: Proofs?

  enum CodingKeys: String, CodingKey {
    case credentialConfigurationId = "credential_configuration_id"
    case proofs
  }
}

// MARK: CredentialRequest.Proofs

extension CredentialRequest {
  struct Proofs: Codable {
    let jwt: [String]
  }
}
