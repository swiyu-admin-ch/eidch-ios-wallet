import BITActivity
import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - NonComplianceFormViewModelError

enum NonComplianceFormViewModelError: Error, Equatable {
  case actorDisplayNotFound
}

// MARK: - NonComplianceFormViewModel

@MainActor
@Observable
final class NonComplianceFormViewModel {

  // MARK: Lifecycle

  init(category: NonComplianceCategory, activityId: UUID) {
    self.category = category
    self.activityId = activityId
  }

  // MARK: Internal

  enum Event {
    case fetchActorDisplay
    case updateForm(NonComplianceFormCheckpointUpdate)
    case sendReport
  }

  private(set) var state = NonComplianceFormViewState.loading
  var destination: NonComplianceInternalDestinations?

  var description = "" {
    didSet {
      validate(.description, value: description)
    }
  }

  var email = "" {
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
    case .fetchActorDisplay: await fetchActorDisplay()
    case .updateForm(let update): updateForm(update)
    case .sendReport: await sendReport()
    }
  }

  // MARK: Private

  private let category: NonComplianceCategory
  private let activityId: UUID
  private var actorDisplay: ActivityActorDisplay?

  @ObservationIgnored @Injected(\.getActivityActorDisplayUseCase) private var getActivityActorDisplayUseCase
  @ObservationIgnored @Injected(\.nonComplianceFormValidator) private var nonComplianceFormValidator
  @ObservationIgnored @Injected(\.submitNonComplianceReportUseCase) private var submitNonComplianceReportUseCase

  private func updateForm(_ update: NonComplianceFormCheckpointUpdate) {
    switch update.field {
    case .description: description = update.value
    case .email: email = update.value
    }
  }

  private func sendReport() async {
    do {
      try await submitNonComplianceReportUseCase.execute(
        category: category,
        description: description,
        email: email.isEmpty ? nil : email,
        activityId: activityId)
      state = .final
    } catch {
      onError(error)
    }
  }

  private func fetchActorDisplay() async {
    if case .result = state { return }
    do {
      actorDisplay = try getActivityActorDisplayUseCase(activityId)
      let resultState = NonComplianceFormViewState.Result(actorImage: actorDisplay?.image, actorName: actorDisplay?.name, isSendingEnabled: false, validations: [:])
      state = .result(resultState)
    } catch {
      state = .error(.actorDisplayNotFound)
    }
  }

  private func onError(_ error: Error) {
    destination = .error(dataset: .retry(error, { navigator in
      navigator.pop()
    }))
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
