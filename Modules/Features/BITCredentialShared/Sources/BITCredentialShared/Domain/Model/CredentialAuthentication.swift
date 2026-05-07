import BITEntities
import BITOpenID
import Foundation

// MARK: - CredentialAuthentication

public struct CredentialAuthentication: Codable, Equatable, Hashable {

  // MARK: Lifecycle

  public init(
    accessToken: String,
    tokenType: AccessToken.TokenType = .bearer,
    refreshToken: String? = nil,
    dpopBinding: KeyBinding? = nil)
  {
    self.accessToken = accessToken
    self.tokenType = tokenType
    self.refreshToken = refreshToken
    self.dpopBinding = dpopBinding
  }

  init(_ entity: CredentialAuthenticationEntity?) {
    guard let entity else {
      /*
       realm requires a one to one relationship to be optional, therefore we have to have
       this fallback here.
       */
      self.init(accessToken: "")
      return
    }
    let tokenType = AccessToken.TokenType(caseInsensitiveRawValue: entity.tokenType) ?? .bearer
    self.init(
      accessToken: entity.accessToken,
      tokenType: tokenType,
      refreshToken: entity.refreshToken,
      dpopBinding: entity.dpopBinding.map(KeyBinding.init))
  }

  // MARK: Public

  public let accessToken: String
  public let tokenType: AccessToken.TokenType
  public let refreshToken: String?
  public let dpopBinding: KeyBinding?
}

extension AccessToken.TokenType {
  init?(caseInsensitiveRawValue rawValue: String) {
    self.init(rawValue: rawValue.lowercased())
  }
}
