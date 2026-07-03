import BITAnyCredentialFormat
import BITVault

// MARK: - FetchAnyCredentialResult

public struct FetchAnyCredentialResult {

  // MARK: Lifecycle

  public init(
    credentials: Credentials,
    authorization: IssuanceAuthorization)
  {
    self.credentials = credentials
    self.authorization = authorization
  }

  public init(
    credentials: Credentials,
    accessToken: String,
    tokenType: AccessToken.TokenType = .bearer,
    refreshToken: String? = nil,
    dpopKeyPair: VaultKeyPair? = nil)
  {
    self.init(
      credentials: credentials,
      authorization: IssuanceAuthorization(
        accessToken: AccessToken(
          accessToken: accessToken,
          tokenType: tokenType,
          refreshToken: refreshToken),
        dpopKeyPair: dpopKeyPair))
  }

  // MARK: Public

  public enum Credentials {
    case credential(AnyCredential)
    case batch(credentials: [AnyCredential])
    case deferred(DeferredCredentialContext)
  }

  public let credentials: Credentials
  public let authorization: IssuanceAuthorization
}
