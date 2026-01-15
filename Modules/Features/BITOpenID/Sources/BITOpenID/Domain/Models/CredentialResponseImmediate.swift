/// Credential Response object for immediate flow as defined in the OID4VCI specification.
/// https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0.html#name-credential-response
struct CredentialResponseImmediate: Decodable, Equatable {
  let credentials: [Credential]
  let notificationId: String?

  enum CodingKeys: String, CodingKey {
    case credentials
    case notificationId = "notification_id"
  }

  struct Credential: Decodable, Equatable {
    let credential: String
  }
}
