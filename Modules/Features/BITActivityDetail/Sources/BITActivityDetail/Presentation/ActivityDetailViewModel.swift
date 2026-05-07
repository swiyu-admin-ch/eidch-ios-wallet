import BITActivity
import BITL10n
import BITTheming
import Factory
import Foundation

// MARK: - ActivityDetailViewModelError

enum ActivityDetailViewModelError: Error {
  case unsupportedCredentialType
}

// MARK: - ActivityDetailViewModel

@MainActor
@Observable
class ActivityDetailViewModel {

  // MARK: Lifecycle

  init(_ activityId: UUID) {
    self.activityId = activityId
  }

  // MARK: Internal

  enum Event {
    case onColorSchemeChange(colorScheme: String)
    case nonComplianceReportSent
    case deleteActivity
    case activityDeletionConfirmed
    case clearToast
  }

  private(set) var state = ActivityDetailState.loading
  var isDeleteConfirmationPresented = false
  var toast: Toast?

  func send(_ event: Event) async {
    switch event {
    case .onColorSchemeChange(let colorScheme):
      loadActivityDetail(for: colorScheme)
    case .nonComplianceReportSent:
      presentNonComplianceReportSent()
    case .deleteActivity:
      presentDeletionConfirmation()
    case .activityDeletionConfirmed:
      deleteActivity()
    case .clearToast:
      clearToast()
    }
  }

  // MARK: Private

  private let activityId: UUID

  @ObservationIgnored @Injected(\.getActivityDetailUseCase) private var getActivityDetailUseCase
  @ObservationIgnored @Injected(\.deleteActivityUseCase) private var deleteActivityUseCase

  private func loadActivityDetail(for colorScheme: String) {
    do {
      let activityDetail = try getActivityDetailUseCase(activityId)
      state = .result(ActivityDetailState.Result(activityDetail, colorScheme: colorScheme))
    } catch {
      state = .error(error)
    }
  }

  private func presentNonComplianceReportSent() {
    toast = Toast(L10n.tkActivityActivityListNonComplianceReportSentTitle)
  }

  private func presentDeletionConfirmation() {
    isDeleteConfirmationPresented = true
  }

  private func deleteActivity() {
    isDeleteConfirmationPresented = false
    try? deleteActivityUseCase(activityId)
  }

  private func clearToast() {
    toast = nil
  }
}
