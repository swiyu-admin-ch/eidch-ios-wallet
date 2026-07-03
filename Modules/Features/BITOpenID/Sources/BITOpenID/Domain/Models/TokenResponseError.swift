import Foundation

struct TokenResponseError: Codable {

  enum Code: String, Codable {
    // https://www.rfc-editor.org/rfc/rfc6749.html#section-5.2
    case invalidRequest = "invalid_request"
    case invalidClient = "invalid_client"
    case invalidGrant = "invalid_grant"
    case unauthorizedClient = "unauthorized_client"
    case unsupportedGrantType = "unsupported_grant_type"
    case invalidScope = "invalid_scope"
    case invalidDPoPProof = "invalid_dpop_proof"
    case useDPoPNonce = "use_dpop_nonce"

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
