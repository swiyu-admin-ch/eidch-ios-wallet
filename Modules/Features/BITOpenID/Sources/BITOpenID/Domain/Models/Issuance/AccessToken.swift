import Foundation

// MARK: - AccessTokenError

enum AccessTokenError: Error {
  case accessTokenDecodingError
}

// MARK: - AccessToken

/// OAuth 2.0 Access Token
/// https://www.rfc-editor.org/rfc/rfc6749.html
/// https://www.rfc-editor.org/rfc/rfc9449.html
public struct AccessToken: Codable, Equatable {

  // MARK: Lifecycle

  public init(
    accessToken: String,
    tokenType: TokenType = .bearer,
    refreshToken: String? = nil)
  {
    self.accessToken = accessToken
    self.tokenType = tokenType
    self.refreshToken = refreshToken
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    accessToken = try container.decode(String.self, forKey: .accessToken)
    refreshToken = try container.decodeIfPresent(String.self, forKey: .refreshToken)

    let rawType = try container.decode(String.self, forKey: .tokenType)
    guard let type = TokenType(rawValue: rawType.lowercased()) else {
      throw AccessTokenError.accessTokenDecodingError
    }
    tokenType = type
  }

  // MARK: Public

  public enum TokenType: String, Codable, Hashable {
    case bearer
    case dpop
  }

  public let accessToken: String
  public let tokenType: TokenType
  public let refreshToken: String?

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case tokenType = "token_type"
    case refreshToken = "refresh_token"
  }

}
