import BITEntities
import Foundation

extension DeferredCredentialEntity {

  public convenience init(_ credential: DeferredCredential) {
    self.init()

    id = credential.transactionId
    accessToken = credential.accessToken
    endpoint = credential.endpoint
    createdAt = credential.createdAt
    progressState = credential.progressionState.rawValue
    pollingInterval = credential.pollingInterval
    polledAt = credential.polledAt
  }
}
