import BITCore
import BITSdJWT
import Foundation

// MARK: - CredentialResponse

/// The Credential Response object as defined in the OID4VCI specification
/// https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0-13.html#name-credential-response
public struct CredentialResponse: Codable, Equatable {

  // MARK: Lifecycle

  public init(rawCredential: String, transactionId: String? = nil, cNonce: String? = nil, cNonceExpiresIn: String? = nil, notificationId: String? = nil) {
    self.rawCredential = rawCredential
    self.transactionId = transactionId
    self.cNonce = cNonce
    self.cNonceExpiresIn = cNonceExpiresIn
    self.notificationId = notificationId
  }

  // MARK: Public

  /// The rawCredential without any treatment
  public let rawCredential: String?

  /// Identifying a deferred issuance transaction
  public let transactionId: String?

  /// A nonce be used to create a proof of possession of key material
  public let cNonce: String?

  /// The lifetime in seconds of the cNonce
  public let cNonceExpiresIn: String?

  /// Identifying an issued Credential
  public let notificationId: String?

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case rawCredential = "credential"
    case transactionId = "transaction_id"
    case cNonce = "c_nonce"
    case cNonceExpiresIn = "c_nonce_expires_in"
    case notificationId = "notification_id"
  }

}
