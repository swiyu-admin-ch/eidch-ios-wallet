import Foundation

// MARK: - AccessTokenError

enum AccessTokenError: Error {
  case accessTokenDecodingError
}

// MARK: - AccessToken

/// OAuth 2.0 Access Token
/// https://www.rfc-editor.org/rfc/pdfrfc/rfc6749.txt.pdf
public struct AccessToken: Codable, Equatable {

  // MARK: Lifecycle

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    accessToken = try container.decode(String.self, forKey: .accessToken)
    expiresIn = try container.decodeIfPresent(Int.self, forKey: .expiresIn)
    refreshToken = try container.decodeIfPresent(String.self, forKey: .refreshToken)
    nonce = try container.decodeIfPresent(String.self, forKey: .nonce)

    let rawType = try container.decode(String.self, forKey: .tokenType)
    guard let type = TokenType(rawValue: rawType.lowercased()) else {
      throw AccessTokenError.accessTokenDecodingError
    }
    tokenType = type
  }

  // MARK: Public

  public enum TokenType: String, Codable {
    case bearer
  }

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case tokenType = "token_type"
    case expiresIn = "expires_in"
    case refreshToken = "refresh_token"
    case nonce = "c_nonce"
  }

  let accessToken: String
  let tokenType: TokenType
  let expiresIn: Int?
  let refreshToken: String?
  let nonce: String?

}
