import BITAnyCredentialFormat

// MARK: - FetchAnyCredentialResult

public struct FetchAnyCredentialResult {

  // MARK: Lifecycle

  public init(
    credentials: Credentials,
    accessToken: String,
    tokenType: AccessToken.TokenType,
    refreshToken: String? = nil)
  {
    self.credentials = credentials
    self.accessToken = accessToken
    self.tokenType = tokenType
    self.refreshToken = refreshToken
  }

  // MARK: Public

  public enum Credentials {
    case credential(AnyCredential)
    case batch(credentials: [AnyCredential])
    case deferred(DeferredCredentialContext)
  }

  public let credentials: Credentials
  public let accessToken: String
  public let tokenType: AccessToken.TokenType
  public let refreshToken: String?

}
