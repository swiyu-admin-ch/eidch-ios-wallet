import BITEntities
import Foundation

extension DeferredCredentialEntity {

  public convenience init(_ credential: DeferredCredential) {
    self.init()

    id = UUID(uuidString: credential.transactionId)?.uuidString ?? UUID().uuidString
    accessToken = credential.accessToken
    endpoint = credential.endpoint
    createdAt = credential.createdAt
    progressState = ProgressionState(credential.progressionState)
    pollingInterval = credential.pollingInterval
    polledAt = credential.polledAt
  }
}

extension DeferredCredentialEntity.ProgressionState {

  init(_ state: DeferredCredential.ProgressionState) {
    switch state {
    case .inProgress:
      self = .inProgress
    case .invalid:
      self = .invalid
    }
  }
}
