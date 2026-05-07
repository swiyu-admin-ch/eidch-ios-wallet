import Foundation

public class FetchDeferredCredentialContext {

  // MARK: Lifecycle

  public init(format: String, accessToken: String, deferredCredentialEndpoint: URL, privateKey: SecKey?, refreshToken: String? = nil) {
    self.format = format
    self.accessToken = accessToken
    self.deferredCredentialEndpoint = deferredCredentialEndpoint
    self.privateKey = privateKey
    self.refreshToken = refreshToken
  }

  // MARK: Public

  public func updateTokens(from accessToken: AccessToken) {
    self.accessToken = accessToken.accessToken
    refreshToken = accessToken.refreshToken ?? refreshToken
  }

  // MARK: Internal

  let format: String
  let deferredCredentialEndpoint: URL
  let privateKey: SecKey?
  var accessToken: String
  var refreshToken: String?

}
