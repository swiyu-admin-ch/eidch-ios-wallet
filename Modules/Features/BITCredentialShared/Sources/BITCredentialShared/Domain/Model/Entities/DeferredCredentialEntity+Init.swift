import BITEntities
import Foundation

extension DeferredCredentialEntity {

  // MARK: Lifecycle

  public convenience init(_ credential: DeferredCredential) {
    self.init()
    id = credential.transactionId
    setValues(from: credential)
  }

  // MARK: Public

  public func setValues(from credential: DeferredCredential) {
    endpoint = credential.endpoint
    createdAt = credential.createdAt
    progressState = credential.progressionState.rawValue
    pollingInterval = credential.pollingInterval
    polledAt = credential.polledAt

    let keyBindingEntities = credential.keyBindings.map(CredentialKeyBindingEntity.init)
    keyBindings.replaceWithUpserted(keyBindingEntities, in: realm)
  }
}
