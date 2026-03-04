import Foundation

public struct DeferredCredentialContext: Codable, Equatable {

  public init(transactionId: String, accessToken: String, endpoint: String, format: String, interval: Int) {
    self.transactionId = transactionId
    self.accessToken = accessToken
    self.endpoint = endpoint
    self.format = format
    self.interval = interval
  }

  public let transactionId: String
  public let accessToken: String
  public let endpoint: String
  public let format: String
  public let interval: Int
}
