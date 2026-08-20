import BITCrypto
import BITVault
import Foundation
import Security

// MARK: - CredentialRequest

/// The Deferred Credential Request object as defined in the OID4VCI specification
/// https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0.html#name-deferred-credential-request
public struct DeferredCredentialRequest: Codable, Equatable {

  public init(transactionId: String, credentialResponseEncryption: CredentialResponseEncryption) {
    self.transactionId = transactionId
    self.credentialResponseEncryption = credentialResponseEncryption
  }

  let transactionId: String
  let credentialResponseEncryption: CredentialResponseEncryption

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case transactionId = "transaction_id"
    case credentialResponseEncryption = "credential_response_encryption"
  }
}
