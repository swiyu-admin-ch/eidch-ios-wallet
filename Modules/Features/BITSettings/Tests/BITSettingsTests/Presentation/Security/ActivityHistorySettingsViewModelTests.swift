// swiftlint:disable force_unwrapping implicitly_unwrapped_optional
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
    viewModel = ActivityHistorySettingsViewModel()
    createSuccessState()
  }

  func testInit_returnsDefaults() {
    XCTAssertEqual(viewModel.isActivityHistoryEnabled, false)
    XCTAssertEqual(viewModel.isConfirmHistoryDisablingAlertPresented, false)
    XCTAssertEqual(viewModel.isConfirmDeletionAlertPresented, false)
    XCTAssertEqual(viewModel.isToastPresented, false)
    XCTAssertEqual(viewModel.toastType, .success)
  }

  func testOnAppear_historyEnabled_returnsHistoryEnabled() async {
    await viewModel.send(.onAppear)

    XCTAssertEqual(viewModel.isActivityHistoryEnabled, true)
    XCTAssertEqual(isActivityHistoryEnabledUseCaseSpy.callAsFunctionCallsCount, 1)
  }

  func testOnAppear_historyDisabled_returnsHistoryDisabled() async {
    isActivityHistoryEnabledUseCaseSpy.callAsFunctionReturnValue = false

    await viewModel.send(.onAppear)

    XCTAssertEqual(viewModel.isActivityHistoryEnabled, false)
  }

  func testOnAppear_repositoryThrows_showsErrorToast() async {
    isActivityHistoryEnabledUseCaseSpy.callAsFunctionThrowableError = TestingError.error

    await viewModel.send(.onAppear)

    XCTAssertTrue(viewModel.isToastPresented)
    XCTAssertEqual(viewModel.toastType, .error)
  }

  func testToggleActivityHistory_historyEnabled_confirmationIsPresented() async {
    viewModel.isActivityHistoryEnabled = true

    await viewModel.send(.toggleActivityHistory)

    XCTAssertEqual(viewModel.isConfirmHistoryDisablingAlertPresented, true)
    XCTAssertFalse(setActivityHistoryEnabledUseCaseSpy.callAsFunctionCalled)
  }

  func testToggleActivityHistory_historyDisabled_returnsHistoryEnabled() async {
    await viewModel.send(.toggleActivityHistory)

    XCTAssertEqual(viewModel.isActivityHistoryEnabled, true)
    XCTAssertEqual(setActivityHistoryEnabledUseCaseSpy.callAsFunctionReceivedIsEnabled, true)
  }

  func testToggleActivityHistory_enablingThrows_showsErrorToast() async {
    setActivityHistoryEnabledUseCaseSpy.callAsFunctionThrowableError = TestingError.error

    await viewModel.send(.toggleActivityHistory)

    XCTAssertEqual(viewModel.isActivityHistoryEnabled, false)
    XCTAssertTrue(viewModel.isToastPresented)
    XCTAssertEqual(viewModel.toastType, .error)
  }

  func testDeleteActivityHistory_confirmationIsPresented() async {
    await viewModel.send(.deleteActivityHistory)

    XCTAssertEqual(viewModel.isConfirmDeletionAlertPresented, true)
    XCTAssertFalse(deleteAllActivitiesUseCaseSpy.callAsFunctionCalled)
  }

  func testConfirmHistoryDisabling_historyEnabled_returnsHistoryDisabled() async {
    viewModel.isConfirmHistoryDisablingAlertPresented = true
    viewModel.isActivityHistoryEnabled = true

    await viewModel.send(.confirmHistoryDisabling)

    XCTAssertEqual(viewModel.isConfirmHistoryDisablingAlertPresented, false)
    XCTAssertEqual(viewModel.isActivityHistoryEnabled, false)
    XCTAssertEqual(setActivityHistoryEnabledUseCaseSpy.callAsFunctionReceivedIsEnabled, false)
  }

  func testConfirmHistoryDisabling_disablingThrows_showsErrorToast() async {
    viewModel.isConfirmHistoryDisablingAlertPresented = true
    viewModel.isActivityHistoryEnabled = true
    setActivityHistoryEnabledUseCaseSpy.callAsFunctionThrowableError = TestingError.error

    await viewModel.send(.confirmHistoryDisabling)

    XCTAssertEqual(viewModel.isConfirmHistoryDisablingAlertPresented, false)
    XCTAssertEqual(viewModel.isActivityHistoryEnabled, true)
    XCTAssertTrue(viewModel.isToastPresented)
    XCTAssertEqual(viewModel.toastType, .error)
  }

  func testConfirmDeletion_deletesActivitiesAndPresentsToast() async {
    viewModel.isConfirmDeletionAlertPresented = true

    await viewModel.send(.confirmDeletion)

    XCTAssertTrue(deleteAllActivitiesUseCaseSpy.callAsFunctionCalled)
    XCTAssertEqual(viewModel.isConfirmDeletionAlertPresented, false)
    XCTAssertTrue(viewModel.isToastPresented)
    XCTAssertEqual(viewModel.toastType, .success)
  }

  func testConfirmDeletion_deletionThrows_showsErrorToast() async {
    viewModel.isConfirmDeletionAlertPresented = true
    deleteAllActivitiesUseCaseSpy.callAsFunctionThrowableError = TestingError.error

    await viewModel.send(.confirmDeletion)

    XCTAssertEqual(viewModel.isConfirmDeletionAlertPresented, false)
    XCTAssertTrue(viewModel.isToastPresented)
    XCTAssertEqual(viewModel.toastType, .error)
  }

  // MARK: Private

  private var viewModel: ActivityHistorySettingsViewModel!

  private var isActivityHistoryEnabledUseCaseSpy: IsActivityHistoryEnabledUseCaseProtocolSpy!
  private var setActivityHistoryEnabledUseCaseSpy: SetActivityHistoryEnabledUseCaseProtocolSpy!
  private var deleteAllActivitiesUseCaseSpy: DeleteAllActivitiesUseCaseProtocolSpy!

  private func registerMocks() {
    isActivityHistoryEnabledUseCaseSpy = IsActivityHistoryEnabledUseCaseProtocolSpy()
    setActivityHistoryEnabledUseCaseSpy = SetActivityHistoryEnabledUseCaseProtocolSpy()
    deleteAllActivitiesUseCaseSpy = DeleteAllActivitiesUseCaseProtocolSpy()

    Container.shared.isActivityHistoryEnabledUseCase.register { self.isActivityHistoryEnabledUseCaseSpy }
    Container.shared.setActivityHistoryEnabledUseCase.register { self.setActivityHistoryEnabledUseCaseSpy }
    Container.shared.deleteAllActivitiesUseCase.register { self.deleteAllActivitiesUseCaseSpy }
  }

  private func createSuccessState() {
    isActivityHistoryEnabledUseCaseSpy.callAsFunctionReturnValue = true
  }
}
