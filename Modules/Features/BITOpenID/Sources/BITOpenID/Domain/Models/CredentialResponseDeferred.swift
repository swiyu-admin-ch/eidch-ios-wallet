/// Credential Response object for deferred flow as defined in the OID4VCI specification.
/// https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0.html#name-credential-response
struct CredentialResponseDeferred: Decodable, Equatable {
  let transactionId: String
  let interval: Int

  enum CodingKeys: String, CodingKey {
    case transactionId = "transaction_id"
    case interval
  }
}
