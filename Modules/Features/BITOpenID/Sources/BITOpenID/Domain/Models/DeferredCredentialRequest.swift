import Foundation

public struct DeferredCredentialRequest: Codable, Equatable {
  public let transactionId: String
  public let accessToken: String
  public let endpoint: String
  public let format: String
  public let interval: Int?
}
