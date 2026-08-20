import BITAnyCredentialFormat
import Foundation

public struct DeferredCredentialContext: Equatable {

  // MARK: Lifecycle

  public init(
    transactionId: String,
    authorization: IssuanceAuthorization,
    endpoint: String,
    format: CredentialFormat,
    interval: Int)
  {
    self.transactionId = transactionId
    self.authorization = authorization
    self.endpoint = endpoint
    self.format = format
    self.interval = interval
  }

  public init(
    transactionId: String,
    accessToken: AccessToken,
    endpoint: String,
    format: CredentialFormat,
    interval: Int)
  {
    self.init(
      transactionId: transactionId,
      authorization: IssuanceAuthorization(accessToken: accessToken),
      endpoint: endpoint,
      format: format,
      interval: interval)
  }

  // MARK: Public

  public let transactionId: String
  public let authorization: IssuanceAuthorization
  public let endpoint: String
  public let format: CredentialFormat
  public let interval: Int

  public var accessToken: AccessToken {
    authorization.accessToken
  }
}
