import Factory
import Foundation
import Testing
@testable import BITActivity
@testable import BITNonCompliance
@testable import BITTestingCore

@MainActor
struct NonComplianceFormViewModelTests {

  // MARK: Lifecycle

  init() {
    let getActivityActorDisplayUseCaseSpy = GetActivityActorDisplayUseCaseProtocolSpy()
    self.getActivityActorDisplayUseCaseSpy = getActivityActorDisplayUseCaseSpy

    let nonComplianceFormValidatorSpy = NonComplianceFormValidatorProtocolSpy()

    self.nonComplianceFormValidatorSpy = nonComplianceFormValidatorSpy

    Container.shared.getActivityActorDisplayUseCase.register { getActivityActorDisplayUseCaseSpy }
    Container.shared.nonComplianceFormValidator.register { nonComplianceFormValidatorSpy }

    viewModel = NonComplianceFormViewModel(category: categoryMock, activityId: activityIdMock)
    getActivityActorDisplayUseCaseSpy.callAsFunctionReturnValue = actorDisplayMock
    nonComplianceFormValidatorSpy.validateForReturnValue = .valid
  }

  // MARK: Internal

  @Test
  func init_stateIsLoadingAndFieldsEmpty() {
    if case .loading = viewModel.state {
      #expect(viewModel.description == "")
      #expect(viewModel.email == "")
    }
  }

  @Test
  func setDescription_descriptionIsSetAndHasStateOfValidator() {
    nonComplianceFormValidatorSpy.validateForReturnValue = .tooShort

    viewModel.description = "test"

    if case .result(let resultState) = viewModel.state {
      #expect(viewModel.description == "test")
      #expect(resultState.validations[.description] == .tooShort)
    }
  }

  @Test
  func setEmail_emailIsSetAndHasStateOfValidator() {
    nonComplianceFormValidatorSpy.validateForReturnValue = .malformed

    viewModel.email = "test"

    if case .result(let resultState) = viewModel.state {
      #expect(viewModel.email == "test")
      #expect(resultState.validations[.email] == .malformed)
    }
  }

  @Test
  func isSendingEnabled_allValid_returnsTrue() {
    viewModel.description = "test"
    viewModel.email = "test"

    if case .result(let resultState) = viewModel.state {
      #expect(resultState.isSendingEnabled == true)
    }
  }

  @Test
  func isSendingEnabled_oneInvalid_returnsFalse() {
    viewModel.description = "test"
    nonComplianceFormValidatorSpy.validateForReturnValue = .malformed
    viewModel.email = "test"

    if case .result(let resultState) = viewModel.state {
      #expect(resultState.isSendingEnabled == false)
    }
  }

  @Test
  func isSendingEnabled_allInvalid_returnsFalse() {
    nonComplianceFormValidatorSpy.validateForReturnValue = .malformed
    viewModel.description = "test"
    viewModel.email = "test"

    if case .result(let resultState) = viewModel.state {
      #expect(resultState.isSendingEnabled == false)
    }
  }

  @Test
  func fetchActorDisplay_loading_stateIsResult() async {
    await viewModel.send(.fetchActorDisplay)

    if case .result(let resultState) = viewModel.state {
      #expect(resultState.actorImage == actorDisplayMock.image)
      #expect(resultState.actorName == actorDisplayMock.name)
      #expect(resultState.isSendingEnabled == false)
      #expect(resultState.validations.isEmpty == true)
    } else {
      Issue.record("Wrong state: \(viewModel.state)")
    }
  }

  @Test
  func fetchActorDisplay_loading_argumentsPassed() async {
    await viewModel.send(.fetchActorDisplay)

    if case .result = viewModel.state {
      #expect(getActivityActorDisplayUseCaseSpy.callAsFunctionCallsCount == 1)
      #expect(getActivityActorDisplayUseCaseSpy.callAsFunctionReceivedActivityId == activityIdMock)
    } else {
      Issue.record("Wrong state: \(viewModel.state)")
    }
  }

  @Test
  func fetchActorDisplay_result_doesNothing() async {
    await viewModel.send(.fetchActorDisplay)
    #expect(getActivityActorDisplayUseCaseSpy.callAsFunctionCallsCount == 1)

    if case .result(let oldState) = viewModel.state {
      await viewModel.send(.fetchActorDisplay)

      if case .result(let resultState) = viewModel.state {
        #expect(getActivityActorDisplayUseCaseSpy.callAsFunctionCallsCount == 1)
        #expect(resultState == oldState)
        return
      }
    }
    Issue.record("Wrong state: \(viewModel.state)")
  }

  @Test
  func fetchActorDisplay_getActivityThrows_errorState() async {
    getActivityActorDisplayUseCaseSpy.callAsFunctionThrowableError = TestingError.error
    await viewModel.send(.fetchActorDisplay)

    if case .error(let error) = viewModel.state {
      #expect(error == .actorDisplayNotFound)
    } else {
      Issue.record("Expected NonComplianceFormViewModelError")
    }
  }

  @Test
  func updateForm_description_setsDescriptionOnly() async {
    let update = NonComplianceFormCheckpointUpdate(field: .description, value: "test")

    await viewModel.send(.fetchActorDisplay)
    await viewModel.send(.updateForm(update))

    if case .result = viewModel.state {
      #expect(viewModel.description == "test")
      #expect(viewModel.email == "")
    } else {
      Issue.record("Wrong state: \(viewModel.state)")
    }
  }

  @Test
  func updateForm_email_setsEmailOnly() async {
    let update = NonComplianceFormCheckpointUpdate(field: .email, value: "test")

    await viewModel.send(.fetchActorDisplay)
    await viewModel.send(.updateForm(update))

    if case .result = viewModel.state {
      #expect(viewModel.email == "test")
      #expect(viewModel.description == "")
    } else {
      Issue.record("Wrong state: \(viewModel.state)")
    }
  }

  @Test
  func sendReport_fails_routeToError() async {
    await viewModel.send(.sendReport)

    if case .error = viewModel.destination {
      #expect(true)
    } else {
      Issue.record("Wrong state: \(viewModel.state)")
    }
  }

  // MARK: Private

  private let activityIdMock = UUID()
  private let credentialIdMock = UUID()
  private let actorDisplayMock = ActivityActorDisplay.Mock.default
  private let categoryMock = NonComplianceCategory.excessiveDataRequest

  private var viewModel: NonComplianceFormViewModel
  private var nonComplianceFormValidatorSpy: NonComplianceFormValidatorProtocolSpy
  private var getActivityActorDisplayUseCaseSpy: GetActivityActorDisplayUseCaseProtocolSpy
}
