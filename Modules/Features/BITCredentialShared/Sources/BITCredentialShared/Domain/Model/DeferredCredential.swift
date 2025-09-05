import BITEntities
import Foundation

// MARK: - DeferredCredential

public struct DeferredCredential: Codable, Equatable {

  public init(transactionId: String, accessToken: String, endpoint: String, createdAt: Date = Date()) {
    self.transactionId = transactionId
    self.accessToken = accessToken
    self.createdAt = createdAt
    self.endpoint = endpoint
  }

  public init(_ entity: DeferredCredentialEntity) {
    self.init(transactionId: entity.id, accessToken: entity.accessToken, endpoint: entity.endpoint, createdAt: entity.createdAt)
  }

  let transactionId: String
  let accessToken: String
  let createdAt: Date
  let endpoint: String
}

extension DeferredCredentialEntity {

  public convenience init(_ credential: DeferredCredential) {
    self.init()

    id = credential.transactionId
    accessToken = credential.accessToken
    endpoint = credential.endpoint
    createdAt = credential.createdAt
  }
}
