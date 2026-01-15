// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITActivity
@testable import BITNonCompliance
@testable import BITTestingCore

@MainActor
final class NonComplianceFormViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() async throws {
    try await super.setUp()
    Container.shared.reset()
    registerMocks()
    viewModel = NonComplianceFormViewModel(category: categoryMock, activityId: activityIdMock)
    await createSuccessState()
  }

  func testInit_stateIsLoadingAndFieldsEmpty() async {
    viewModel = NonComplianceFormViewModel(category: categoryMock, activityId: activityIdMock)

    if case .loading = viewModel.state {
      XCTAssertEqual(viewModel.description, "")
      XCTAssertEqual(viewModel.email, "")
    }
  }

  func testSetDescription_descriptionIsSetAndHasStateOfValidator() {
    nonComplianceFormValidatorSpy.validateForReturnValue = .tooShort

    viewModel.description = "test"

    if case .result(let resultState) = viewModel.state {
      XCTAssertEqual(viewModel.description, "test")
      XCTAssertEqual(resultState.validations[.description], .tooShort)
    }
  }

  func testSetEmail_emailIsSetAndHasStateOfValidator() {
    nonComplianceFormValidatorSpy.validateForReturnValue = .malformed

    viewModel.email = "test"

    if case .result(let resultState) = viewModel.state {
      XCTAssertEqual(viewModel.email, "test")
      XCTAssertEqual(resultState.validations[.email], .malformed)
    }
  }

  func testIsSendingEnabled_allValid_returnsTrue() {
    viewModel.description = "test"
    viewModel.email = "test"

    if case .result(let resultState) = viewModel.state {
      XCTAssertEqual(resultState.isSendingEnabled, true)
    }
  }

  func testIsSendingEnabled_oneInvalid_returnsFalse() {
    viewModel.description = "test"
    nonComplianceFormValidatorSpy.validateForReturnValue = .malformed
    viewModel.email = "test"

    if case .result(let resultState) = viewModel.state {
      XCTAssertEqual(resultState.isSendingEnabled, false)
    }
  }

  func testIsSendingEnabled_allInvalid_returnsFalse() {
    nonComplianceFormValidatorSpy.validateForReturnValue = .malformed
    viewModel.description = "test"
    viewModel.email = "test"

    if case .result(let resultState) = viewModel.state {
      XCTAssertEqual(resultState.isSendingEnabled, false)
    }
  }

  func testFetchActivity_loading_stateIsResult() async {
    viewModel = NonComplianceFormViewModel(category: categoryMock, activityId: activityIdMock)

    await viewModel.send(.fetchActivity)

    if case .result(let resultState) = viewModel.state {
      XCTAssertEqual(resultState.actorImage, activityMock.actorDisplays.findDisplayWithFallback()?.image)
      XCTAssertEqual(resultState.actorName, activityMock.actorDisplays.findDisplayWithFallback()?.name)
      XCTAssertEqual(resultState.isSendingEnabled, false)
      XCTAssertTrue(resultState.validations.isEmpty)
    } else {
      XCTFail("Wrong state: \(viewModel.state)")
    }
  }

  func testFetchActivity_loading_argumentsPassed() async {
    XCTAssertEqual(getActivityUseCaseSpy.callAsFunctionCallsCount, 1)
    viewModel = NonComplianceFormViewModel(category: categoryMock, activityId: activityIdMock)

    await viewModel.send(.fetchActivity)

    if case .result = viewModel.state {
      XCTAssertEqual(getActivityUseCaseSpy.callAsFunctionCallsCount, 2)
      XCTAssertEqual(getActivityUseCaseSpy.callAsFunctionReceivedActivityId, activityIdMock)
    } else {
      XCTFail("Wrong state: \(viewModel.state)")
    }
  }

  func testFetchActivity_result_doesNothing() async {
    XCTAssertEqual(getActivityUseCaseSpy.callAsFunctionCallsCount, 1)
    if case .result(let oldState) = viewModel.state {
      await viewModel.send(.fetchActivity)

      if case .result(let resultState) = viewModel.state {
        XCTAssertEqual(getActivityUseCaseSpy.callAsFunctionCallsCount, 1)
        XCTAssertEqual(resultState, oldState)
        return
      }
    }
    XCTFail("Wrong state: \(viewModel.state)")
  }

  func testFetchActivity_getActivityThrows_errorState() async {
    getActivityUseCaseSpy.callAsFunctionThrowableError = TestingError.error
    viewModel = NonComplianceFormViewModel(category: categoryMock, activityId: activityIdMock)

    await viewModel.send(.fetchActivity)

    if case .error(let error) = viewModel.state {
      XCTAssertEqual(error, .activityNotFound)
    } else {
      XCTFail("Expected NonComplianceFormViewModelError")
    }
  }

  func testUpdateForm_description_setsDescriptionOnly() async {
    let update = NonComplianceFormCheckpointUpdate(field: .description, value: "test")

    await viewModel.send(.updateForm(update))

    if case .result = viewModel.state {
      XCTAssertEqual(viewModel.description, "test")
      XCTAssertEqual(viewModel.email, "")
    } else {
      XCTFail("Wrong state: \(viewModel.state)")
    }
  }

  func testUpdateForm_email_setsEmailOnly() async {
    let update = NonComplianceFormCheckpointUpdate(field: .email, value: "test")

    await viewModel.send(.updateForm(update))

    if case .result = viewModel.state {
      XCTAssertEqual(viewModel.email, "test")
      XCTAssertEqual(viewModel.description, "")
    } else {
      XCTFail("Wrong state: \(viewModel.state)")
    }
  }

  // MARK: Private

  private var viewModel: NonComplianceFormViewModel!
  private let activityIdMock = UUID()
  private let credentialIdMock = UUID()
  private let categoryMock = NonComplianceCategory.excessiveDataRequest
  private let activityMock = Activity.Mock.issueTrusted

  private var getActivityUseCaseSpy: GetActivityUseCaseProtocolSpy!
  private var nonComplianceFormValidatorSpy: NonComplianceFormValidatorProtocolSpy!

  private func registerMocks() {
    getActivityUseCaseSpy = GetActivityUseCaseProtocolSpy()
    nonComplianceFormValidatorSpy = NonComplianceFormValidatorProtocolSpy()

    Container.shared.getActivityUseCase.register { self.getActivityUseCaseSpy }
    Container.shared.nonComplianceFormValidator.register { self.nonComplianceFormValidatorSpy }
  }

  private func createSuccessState() async {
    getActivityUseCaseSpy.callAsFunctionReturnValue = activityMock
    nonComplianceFormValidatorSpy.validateForReturnValue = .valid
    await viewModel.send(.fetchActivity)
  }
}
