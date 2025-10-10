import BITEntities
import Foundation

extension VerifiableCredentialEntity {

  public convenience init(_ credential: VerifiableCredential) {
    self.init()

    id = UUID()
    createdAt = credential.createdAt
    progressionState = ProgressionState(credential.progressionState)
    payload = credential.payload
    issuer = credential.issuer
    status = VerifiableCredentialEntity.CredentialStatus(credential.status)

    let sortedClusters = credential.clusters.sorted(by: { $0.order < $1.order })
    clusters.insert(contentsOf: sortedClusters.map(CredentialClaimClusterEntity.init), at: 0)

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
