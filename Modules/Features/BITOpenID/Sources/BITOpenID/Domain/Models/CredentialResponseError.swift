import Foundation

struct CredentialResponseError: Codable {

  enum Code: String, Codable {
    // https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0.html#section-8.3.1.2
    case credentialRequestDenied = "credential_request_denied"
    case invalidCredentialRequest = "invalid_credential_request"
    case invalidEncryptionParameters = "invalid_encryption_parameters"
    case invalidNonce = "invalid_nonce"
    case invalidProof = "invalid_proof"
    case unknownCredentialConfiguration = "unknown_credential_configuration"
    case unknownCredentialIdentifier = "unknown_credential_identifier"
    case invalidTransactionId = "invalid_transaction_id"

    // https://www.rfc-editor.org/rfc/rfc6750.html#section-3.1
    case invalidRequest = "invalid_request"
    case invalidToken = "invalid_token"
    case insufficientScope = "insufficient_scope"

    // MARK: Lifecycle

    init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let rawValue = try container.decode(String.self).lowercased()

      guard let code = Code(rawValue: rawValue) else {
        throw DecodingError.dataCorruptedError(
          in: container,
          debugDescription: "Couldn't decode token response error: \(rawValue)")
      }

      self = code
    }
  }

  let error: Code
}
