import BITActivity
import BITCredential
import BITCredentialShared
import BITOpenID
import Foundation

// MARK: - ActivityCredentialViewModel

struct ActivityCredentialViewModel: Equatable {

  // MARK: Lifecycle

  init(detail: ActivityDetail, colorScheme: String) {
    let display = detail.credential.getDisplay(for: colorScheme)
    name = display?.name
    summary = display?.summary
    backgroundColor = display?.backgroundColor
    logoBase64 = display?.logoBase64
    environment = detail.credential.environment
    clusters = detail.credential.clusters
  }

  // MARK: Internal

  let name: String?
  let summary: String?
  let backgroundColor: String?
  let logoBase64: Data?
  let environment: TrustEnvironment
  let clusters: [CredentialClaimCluster]

  // MARK: Private
}

extension ActivityDetailCredential {
  fileprivate func getDisplay(for colorScheme: String) -> CredentialDisplay? {
    displays.first(where: { $0.theme == colorScheme }) ?? displays.first
  }
}
