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
    statusListState = detail.credential.statusListState
  }

  // MARK: Internal

  let name: String?
  let summary: String?
  let backgroundColor: String?
  let logoBase64: Data?
  let environment: TrustEnvironment
  let clusters: [CredentialClaimCluster]

  let statusListState: CredentialStatus?

  /// The status the badge shows, or `nil` when there is nothing to show: everything the badge
  /// needs comes from it, so it either shows in full or not at all.
  var displayedStatus: CredentialStatus? {
    guard let statusListState else { return nil }

    return switch statusListState {
    case .revoked,
         .suspended,
         .valid: statusListState
    case .businessExpired,
         .expired,
         .notYetValid,
         .unknown,
         .unsupported: nil
    }
  }
}

extension ActivityDetailCredential {
  fileprivate func getDisplay(for colorScheme: String) -> CredentialDisplay? {
    displays.first(where: { $0.theme == colorScheme }) ?? displays.first
  }
}
