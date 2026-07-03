import Foundation
import Security

public struct FetchDeferredCredentialContext {

  // MARK: Lifecycle

  public init(
    format: String,
    authorization: IssuanceAuthorization,
    deferredCredentialEndpoint: URL,
    privateKey: SecKey?)
  {
    self.format = format
    self.authorization = authorization
    self.deferredCredentialEndpoint = deferredCredentialEndpoint
    self.privateKey = privateKey
  }

  // MARK: Public

  public let authorization: IssuanceAuthorization
  public let format: String
  public let deferredCredentialEndpoint: URL
  public let privateKey: SecKey?

  // MARK: Internal
}
