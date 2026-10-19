import BITEntities
import Foundation

extension VerifiableCredentialEntity {

  // MARK: Lifecycle

  public convenience init(_ credential: VerifiableCredential) {
    self.init()
    id = UUID()
    setValues(from: credential)
  }

  // MARK: Public

  public func setValues(from credential: VerifiableCredential) {
    createdAt = credential.createdAt
    refreshedAt = credential.refreshedAt
    lastRefreshAttemptAt = credential.lastRefreshAttemptAt
    progressionState = ProgressionState(credential.progressionState)
    issuer = credential.issuer
    let bundleItemEntities = credential.bundleItems.map(BundleItemEntity.init)
    bundleItems.replaceWithUpserted(bundleItemEntities, in: realm)
    nextPresentableBundleItemId = credential.nextPresentableBundleItemId

    batchData = credential.batchData.flatMap(BatchDataEntity.init)

    validFrom = credential.validFrom
    validUntil = credential.validUntil
  }
}

extension VerifiableCredentialEntity.ProgressionState {

  init(_ state: VerifiableCredential.ProgressState) {
    switch state {
    case .accepted:
      self = .accepted
    case .unaccepted:
      self = .unaccepted
    }
  }
}
