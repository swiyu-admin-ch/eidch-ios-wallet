import BITVault
import Foundation

// MARK: - IssuanceAuthorization

/// In-memory authorization state for an issuance session.
public struct IssuanceAuthorization: Equatable {

  // MARK: Lifecycle

  public init(
    accessToken: AccessToken,
    dpopKeyPair: VaultKeyPair? = nil,
    resourceServerDPoPNonce: String? = nil)
  {
    self.accessToken = accessToken
    self.dpopKeyPair = dpopKeyPair
    self.resourceServerDPoPNonce = resourceServerDPoPNonce
  }

  public init(
    accessToken: String,
    accessTokenType: AccessToken.TokenType = .bearer,
    refreshToken: String? = nil,
    dpopKeyPair: VaultKeyPair? = nil,
    dpopNonce: String? = nil)
  {
    self.init(
      accessToken: AccessToken(
        accessToken: accessToken,
        tokenType: accessTokenType,
        refreshToken: refreshToken),
      dpopKeyPair: dpopKeyPair,
      resourceServerDPoPNonce: dpopNonce)
  }

  // MARK: Public

  public let accessToken: AccessToken
  public let dpopKeyPair: VaultKeyPair?
  public let resourceServerDPoPNonce: String?

  public var accessTokenType: AccessToken.TokenType {
    accessToken.tokenType
  }

  public var refreshToken: String? {
    accessToken.refreshToken
  }
}

@available(*, deprecated, renamed: "IssuanceAuthorization")
public typealias ProtectedResourceAuthorization = IssuanceAuthorization
