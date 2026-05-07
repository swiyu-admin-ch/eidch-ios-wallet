import BITActivity
import BITL10n
import BITTheming
import Combine
import Factory
import Foundation

// MARK: - ActivityHistorySettingsViewModel

@MainActor
@Observable
class ActivityHistorySettingsViewModel {

  // MARK: Lifecycle

  init(getActivityHistoryEnabledSubject: GetActivityHistoryEnabledSubjectUseCaseProtocol) {
    getActivityHistoryEnabledSubject()
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { [weak self] in
        self?.isActivityHistoryEnabled = $0
      }).store(in: &cancellables)
  }

  // MARK: Internal

  enum Event {
    case toggleActivityHistory
    case deleteActivityHistory
    case confirmHistoryDisabling
    case confirmDeletion
    case clearToast
  }

  var isActivityHistoryEnabled = false
  var isConfirmHistoryDisablingAlertPresented = false
  var isConfirmDeletionAlertPresented = false
  var toast: Toast?

  func send(_ event: Event) async {
    do {
      switch event {
      case .toggleActivityHistory:
        try toggleActivityHistory()
      case .deleteActivityHistory:
        showDeletionConfirmation()
      case .confirmHistoryDisabling:
        try confirmHistoryDisabling()
      case .confirmDeletion:
        try confirmDeletion()
      case .clearToast:
        clearToast()
      }
    } catch {
      toast = Toast(L10n.tkErrorGenericPrimary, type: .error)
    }
  }

  // MARK: Private

  @ObservationIgnored @Injected(\.setActivityHistoryEnabledUseCase) private var setActivityHistoryEnabledUseCase
  @ObservationIgnored @Injected(\.deleteAllActivitiesUseCase) private var deleteAllActivitiesUseCase
  @ObservationIgnored private var cancellables = Set<AnyCancellable>()

  private func toggleActivityHistory() throws {
    if isActivityHistoryEnabled {
      isConfirmHistoryDisablingAlertPresented = true
    } else {
      try setActivityHistoryEnabledUseCase(true)
    }
  }

  private func showDeletionConfirmation() {
    isConfirmDeletionAlertPresented = true
  }

  private func confirmHistoryDisabling() throws {
    isConfirmHistoryDisablingAlertPresented = false
    try setActivityHistoryEnabledUseCase(false)
  }

  private func confirmDeletion() throws {
    isConfirmDeletionAlertPresented = false
    try deleteAllActivitiesUseCase()
    toast = Toast(L10n.tkSettingsActivityHistoryDeletionSuccessMessage)
  }

  private func clearToast() {
    toast = nil
  }
}
