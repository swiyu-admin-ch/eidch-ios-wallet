import BITActivity
import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - NonComplianceFormViewModelError

enum NonComplianceFormViewModelError: Error, Equatable {
  case activityNotFound
}

// MARK: - NonComplianceFormViewModel

@MainActor
class NonComplianceFormViewModel: ObservableObject {

  // MARK: Lifecycle

  init(category: NonComplianceCategory, activityId: UUID) {
    self.category = category
    self.activityId = activityId
  }

  // MARK: Internal

  enum Event {
    case fetchActivity
    case updateForm(NonComplianceFormCheckpointUpdate)
    case sendReport
  }

  @Published private(set) var state = NonComplianceFormViewState.loading
  @Published var destination: NonComplianceInternalDestinations?

  @Published var description = "" {
    didSet {
      validate(.description, value: description)
    }
  }

  @Published var email = "" {
    didSet {
      validate(.email, value: email)
    }
  }

  var title: String {
    switch category {
    case .excessiveDataRequest: L10n.tkNonComplianceReportExcessiveDataTitle
    }
  }

  func send(_ event: Event) async {
    switch event {
    case .fetchActivity: await fetchActivity()
    case .updateForm(let update): updateForm(update)
    case .sendReport: await sendReport()
    }
  }

  // MARK: Private

  private let category: NonComplianceCategory
  private let activityId: UUID
  private var activity: Activity?

  @Injected(\.getActivityUseCase) private var getActivityUseCase
  @Injected(\.nonComplianceFormValidator) private var nonComplianceFormValidator
  @Injected(\.submitNonComplianceReportUseCase) private var submitNonComplianceReportUseCase

  private func updateForm(_ update: NonComplianceFormCheckpointUpdate) {
    switch update.field {
    case .description: description = update.value
    case .email: email = update.value
    }
  }

  private func sendReport() async {
    do {
      guard let activity else {
        throw NonComplianceFormViewModelError.activityNotFound
      }
      try await submitNonComplianceReportUseCase.execute(
        category: category,
        description: description,
        email: email.isEmpty ? nil : email,
        activity: activity)
      state = .final
    } catch {
      onError(error)
    }
  }

  private func fetchActivity() async {
    if case .result = state { return }
    do {
      activity = try getActivityUseCase(activityId)
      let display = activity?.actorDisplays.findDisplayWithFallback()
      let resultState = NonComplianceFormViewState.Result(actorImage: display?.image, actorName: display?.name, isSendingEnabled: false, validations: [:])
      state = .result(resultState)
    } catch {
      state = .error(.activityNotFound)
    }
  }

  private func onError(_ error: Error) {
    destination = .error(dataset: .retry(error, { _ in } ))
  }

  private func validate(_ field: NonComplianceFormField, value: String) {
    if case .result(var resultState) = state {
      var validations = resultState.validations
      validations[field] = nonComplianceFormValidator.validate(value, for: field)
      resultState = resultState.changing(\.validations, to: validations)
      resultState = resultState.changing(
        \.isSendingEnabled,
        to: resultState.validations.map(\.key).contains(NonComplianceFormField.mandatoryFields) && resultState.validations.allSatisfy { $0.value == .valid })
      state = .result(resultState)
    }
  }
}
