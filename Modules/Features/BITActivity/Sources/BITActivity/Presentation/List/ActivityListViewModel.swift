import BITL10n
import Factory
import SwiftUI

@MainActor
class ActivityListViewModel: ObservableObject {

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

  @Published private(set) var state = State.loading
  @Published var isToastPresented = false
  @Published private(set) var toastMessage: String?

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
    toastMessage = L10n.tkActivityActivityListEntryDeletedTitle
    isToastPresented = true
  }

  func clearToast() {
    isToastPresented = false
    toastMessage = nil
  }

  // MARK: Private

  private let credentialId: UUID

  @Injected(\.getCredentialActivitiesUseCase) private var getCredentialActivitiesUseCase

}
