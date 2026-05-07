import BITL10n
import BITTheming
import Factory
import SwiftUI

@MainActor
@Observable
class ActivityListViewModel {

  // MARK: Lifecycle

  init(_ credentialId: UUID) {
    self.credentialId = credentialId
  }

  // MARK: Internal

  enum State {
    case loading
    case result([ActivityCellViewModel])
    case error(Error)
  }

  private(set) var state = State.loading
  var toast: Toast?

  func fetchActivities() async {
    withAnimation {
      do {
        let activities = try getCredentialActivitiesUseCase(for: credentialId).map(ActivityCellViewModel.init)
        state = .result(activities)
      } catch {
        state = .error(error)
      }
    }
  }

  func showActivityDeleted() {
    toast = Toast(L10n.tkActivityActivityListEntryDeletedTitle)
  }

  // MARK: Private

  private let credentialId: UUID

  @ObservationIgnored @Injected(\.getCredentialActivitiesUseCase) private var getCredentialActivitiesUseCase

}
