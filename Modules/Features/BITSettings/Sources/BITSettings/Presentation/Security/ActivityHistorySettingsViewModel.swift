import BITActivity
import BITL10n
import BITTheming
import Factory
import Foundation

// MARK: - ActivityHistorySettingsViewModel

@MainActor
class ActivityHistorySettingsViewModel: ObservableObject {

  // MARK: Internal

  enum Event {
    case onAppear
    case toggleActivityHistory
    case deleteActivityHistory
    case confirmHistoryDisabling
    case confirmDeletion
    case clearToast
  }

  @Published var isActivityHistoryEnabled = false
  @Published var isConfirmHistoryDisablingAlertPresented = false
  @Published var isConfirmDeletionAlertPresented = false
  @Published var isToastPresented = false
  @Published var toastType = ToastType.success

  func send(_ event: Event) async {
    do {
      switch event {
      case .onAppear:
        try onAppear()
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
      toastType = .error
      isToastPresented = true
    }
  }

  // MARK: Private

  @Injected(\.isActivityHistoryEnabledUseCase) private var isActivityHistoryEnabledUseCase
  @Injected(\.setActivityHistoryEnabledUseCase) private var setActivityHistoryEnabledUseCase
  @Injected(\.deleteAllActivitiesUseCase) private var deleteAllActivitiesUseCase

  private func onAppear() throws {
    isActivityHistoryEnabled = try isActivityHistoryEnabledUseCase()
  }

  private func toggleActivityHistory() throws {
    if isActivityHistoryEnabled {
      isConfirmHistoryDisablingAlertPresented = true
    } else {
      try setActivityHistoryEnabledUseCase(true)
      isActivityHistoryEnabled = true
    }
  }

  private func showDeletionConfirmation() {
    isConfirmDeletionAlertPresented = true
  }

  private func confirmHistoryDisabling() throws {
    isConfirmHistoryDisablingAlertPresented = false
    try setActivityHistoryEnabledUseCase(false)
    isActivityHistoryEnabled = false
  }

  private func confirmDeletion() throws {
    isConfirmDeletionAlertPresented = false
    try deleteAllActivitiesUseCase()
    isToastPresented = true
    toastType = .success
  }

  private func clearToast() {
    isToastPresented = false
    toastType = .success
  }
}
