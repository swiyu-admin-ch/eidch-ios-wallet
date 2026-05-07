// swiftlint:disable force_unwrapping implicitly_unwrapped_optional
import Combine
import Factory
import XCTest
@testable import BITActivity
@testable import BITSettings
@testable import BITTestingCore
@testable import BITTheming

@MainActor
class ActivityHistorySettingsViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.reset()
    registerMocks()
    createSuccessState()
    viewModel = ActivityHistorySettingsViewModel(getActivityHistoryEnabledSubject: getActivityHistoryEnabledSubjectUseCaseSpy)
  }

  func testInit_returnsDefaults() {
    XCTAssertEqual(viewModel.isActivityHistoryEnabled, false)
    XCTAssertEqual(viewModel.isConfirmHistoryDisablingAlertPresented, false)
    XCTAssertEqual(viewModel.isConfirmDeletionAlertPresented, false)
    XCTAssertNil(viewModel.toast)

    XCTAssertEqual(getActivityHistoryEnabledSubjectUseCaseSpy.callAsFunctionCallsCount, 1)
  }

  func testToggleActivityHistory_historyEnabled_confirmationIsPresented() async {
    viewModel.isActivityHistoryEnabled = true

    await viewModel.send(.toggleActivityHistory)

    XCTAssertEqual(viewModel.isConfirmHistoryDisablingAlertPresented, true)
    XCTAssertFalse(setActivityHistoryEnabledUseCaseSpy.callAsFunctionCalled)
  }

  func testToggleActivityHistory_historyDisabled_argumentsPassed() async {
    await viewModel.send(.toggleActivityHistory)

    XCTAssertEqual(setActivityHistoryEnabledUseCaseSpy.callAsFunctionReceivedIsEnabled, true)
  }

  func testToggleActivityHistory_enablingThrows_showsErrorToast() async {
    setActivityHistoryEnabledUseCaseSpy.callAsFunctionThrowableError = TestingError.error

    await viewModel.send(.toggleActivityHistory)

    XCTAssertEqual(viewModel.isActivityHistoryEnabled, false)
    XCTAssertNotNil(viewModel.toast)
    XCTAssertEqual(viewModel.toast?.type, .error)
  }

  func testDeleteActivityHistory_confirmationIsPresented() async {
    await viewModel.send(.deleteActivityHistory)

    XCTAssertEqual(viewModel.isConfirmDeletionAlertPresented, true)
    XCTAssertFalse(deleteAllActivitiesUseCaseSpy.callAsFunctionCalled)
  }

  func testConfirmHistoryDisabling_historyEnabled_hidesAlertAndPassesArguments() async {
    viewModel.isConfirmHistoryDisablingAlertPresented = true
    viewModel.isActivityHistoryEnabled = true

    await viewModel.send(.confirmHistoryDisabling)

    XCTAssertEqual(viewModel.isConfirmHistoryDisablingAlertPresented, false)
    XCTAssertEqual(setActivityHistoryEnabledUseCaseSpy.callAsFunctionReceivedIsEnabled, false)
  }

  func testConfirmHistoryDisabling_disablingThrows_showsErrorToast() async {
    viewModel.isConfirmHistoryDisablingAlertPresented = true
    viewModel.isActivityHistoryEnabled = true
    setActivityHistoryEnabledUseCaseSpy.callAsFunctionThrowableError = TestingError.error

    await viewModel.send(.confirmHistoryDisabling)

    XCTAssertEqual(viewModel.isConfirmHistoryDisablingAlertPresented, false)
    XCTAssertEqual(viewModel.isActivityHistoryEnabled, true)
    XCTAssertNotNil(viewModel.toast)
    XCTAssertEqual(viewModel.toast?.type, .error)
  }

  func testConfirmDeletion_deletesActivitiesAndPresentsToast() async {
    viewModel.isConfirmDeletionAlertPresented = true

    await viewModel.send(.confirmDeletion)

    XCTAssertTrue(deleteAllActivitiesUseCaseSpy.callAsFunctionCalled)
    XCTAssertEqual(viewModel.isConfirmDeletionAlertPresented, false)
    XCTAssertNotNil(viewModel.toast)
    XCTAssertEqual(viewModel.toast?.type, .success)
  }

  func testConfirmDeletion_deletionThrows_showsErrorToast() async {
    viewModel.isConfirmDeletionAlertPresented = true
    deleteAllActivitiesUseCaseSpy.callAsFunctionThrowableError = TestingError.error

    await viewModel.send(.confirmDeletion)

    XCTAssertEqual(viewModel.isConfirmDeletionAlertPresented, false)
    XCTAssertNotNil(viewModel.toast)
    XCTAssertEqual(viewModel.toast?.type, .error)
  }

  func testGetActivityHistoryEnabledSubjectReceive_newValue_setsValue() async {
    subjectMock.send(true)

    try? await Task.sleep(nanoseconds: 1_000_000)

    XCTAssertTrue(viewModel.isActivityHistoryEnabled)
  }

  // MARK: Private

  private var viewModel: ActivityHistorySettingsViewModel!

  private var subjectMock: CurrentValueSubject<Bool, Never>!

  private var getActivityHistoryEnabledSubjectUseCaseSpy: GetActivityHistoryEnabledSubjectUseCaseProtocolSpy!
  private var setActivityHistoryEnabledUseCaseSpy: SetActivityHistoryEnabledUseCaseProtocolSpy!
  private var deleteAllActivitiesUseCaseSpy: DeleteAllActivitiesUseCaseProtocolSpy!

  private func registerMocks() {
    subjectMock = CurrentValueSubject(false)
    getActivityHistoryEnabledSubjectUseCaseSpy = GetActivityHistoryEnabledSubjectUseCaseProtocolSpy()
    setActivityHistoryEnabledUseCaseSpy = SetActivityHistoryEnabledUseCaseProtocolSpy()
    deleteAllActivitiesUseCaseSpy = DeleteAllActivitiesUseCaseProtocolSpy()

    Container.shared.getActivityHistoryEnabledSubjectUseCase.register { @MainActor in self.getActivityHistoryEnabledSubjectUseCaseSpy }
    Container.shared.setActivityHistoryEnabledUseCase.register { @MainActor in self.setActivityHistoryEnabledUseCaseSpy }
    Container.shared.deleteAllActivitiesUseCase.register { @MainActor in self.deleteAllActivitiesUseCaseSpy }
  }

  private func createSuccessState() {
    getActivityHistoryEnabledSubjectUseCaseSpy.callAsFunctionReturnValue = subjectMock
  }
}
