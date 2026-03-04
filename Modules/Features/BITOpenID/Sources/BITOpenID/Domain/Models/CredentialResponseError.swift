import Foundation

struct CredentialResponseError: Codable {

  // MARK: Internal

  enum Code: String, Codable {
    case invalidCredentialRequest = "INVALID_CREDENTIAL_REQUEST"
    case unknownCredentialConfiguration = "UNKNOWN_CREDENTIAL_CONFIGURATION"
    case unknownCredentialIdentifier = "UNKNOWN_CREDENTIAL_IDENTIFIER"
    case invalidProof = "INVALID_PROOF"
    case invalidNonce = "INVALID_NONCE"
    case invalidEncryptionParameters = "INVALID_ENCRYPTION_PARAMETERS"
    case credentialRequestDenied = "CREDENTIAL_REQUEST_DENIED"
  }

  let error: Code

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case error
    case errorDescription = "error_description"
  }

  private let errorDescription: String
}
