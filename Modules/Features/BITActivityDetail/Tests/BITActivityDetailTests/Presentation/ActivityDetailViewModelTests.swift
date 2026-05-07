// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITActivity
@testable import BITActivityDetail
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITL10n
@testable import BITTestingCore
@testable import BITTheming

@MainActor
final class ActivityDetailViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    viewModel = ActivityDetailViewModel(activityIdMock)
    createSuccessState()
  }

  func testOnColorScheme_success_stateIsResult() async {
    await viewModel.send(.onColorSchemeChange(colorScheme: colorSchemeMock))

    if case .result(let result) = viewModel.state {
      XCTAssertEqual(result.activity.id, activityDetailMock.id)
      XCTAssertEqual(result.credential.name, activityDetailMock.credential.displays.first?.name)
      XCTAssertEqual(result.credential.clusters.count, 1)
      XCTAssertEqual(result.actor.name, activityDetailMock.actorDisplay?.name)
    } else {
      XCTFail("Expected result state")
    }
  }

  func testOnColorScheme_success_passesArguments() async {
    await viewModel.send(.onColorSchemeChange(colorScheme: colorSchemeMock))

    XCTAssertEqual(getActivityDetailUseCaseSpy.callAsFunctionReceivedActivityId, activityIdMock)
  }

  func testOnColorScheme_useCaseThrowsError_stateIsError() async {
    getActivityDetailUseCaseSpy.callAsFunctionThrowableError = TestingError.error

    await viewModel.send(.onColorSchemeChange(colorScheme: colorSchemeMock))

    if case .error(let error) = viewModel.state {
      XCTAssertEqual(error as? TestingError, .error)
    } else {
      XCTFail("Expected error state")
    }
  }

  func testDeleteActivity_deleteConfirmationPresented() async {
    XCTAssertFalse(viewModel.isDeleteConfirmationPresented)

    await viewModel.send(.deleteActivity)

    XCTAssertTrue(viewModel.isDeleteConfirmationPresented)
  }

  func testActivityDeletionConfirmed_success_hidesDeleteConfirmation() async {
    viewModel.isDeleteConfirmationPresented = true

    await viewModel.send(.activityDeletionConfirmed)

    XCTAssertFalse(viewModel.isDeleteConfirmationPresented)
    XCTAssertEqual(deleteActivityUseCaseSpy.callAsFunctionCallsCount, 1)
    XCTAssertEqual(deleteActivityUseCaseSpy.callAsFunctionReceivedActivityId, activityIdMock)
  }

  func testActivityDeletionConfirmed_useCaseThrowsError_justRuns() async {
    viewModel.isDeleteConfirmationPresented = true
    deleteActivityUseCaseSpy.callAsFunctionThrowableError = TestingError.error

    await viewModel.send(.activityDeletionConfirmed)

    XCTAssertFalse(viewModel.isDeleteConfirmationPresented)
  }

  func testNonComplianceReportSent_setsToast() async {
    XCTAssertNil(viewModel.toast)

    await viewModel.send(.nonComplianceReportSent)

    XCTAssertNotNil(viewModel.toast)
  }

  func testClearToast_resetsToastState() async {
    viewModel.toast = Toast("test")

    await viewModel.send(.clearToast)

    XCTAssertNil(viewModel.toast)
  }

  // MARK: Private

  private let colorSchemeMock = "colorScheme"
  private let activityIdMock = UUID()
  private let activityDetailMock = ActivityDetail.Mock.trustedIssuance

  private var getActivityDetailUseCaseSpy: GetActivityDetailUseCaseProtocolSpy!
  private var deleteActivityUseCaseSpy: DeleteActivityUseCaseProtocolSpy!

  private var viewModel: ActivityDetailViewModel!

  private func registerMocks() {
    getActivityDetailUseCaseSpy = GetActivityDetailUseCaseProtocolSpy()
    deleteActivityUseCaseSpy = DeleteActivityUseCaseProtocolSpy()
    Container.shared.getActivityDetailUseCase.register { @MainActor in self.getActivityDetailUseCaseSpy }
    Container.shared.deleteActivityUseCase.register { @MainActor in self.deleteActivityUseCaseSpy }
  }

  private func createSuccessState() {
    getActivityDetailUseCaseSpy.callAsFunctionReturnValue = activityDetailMock
  }
}
