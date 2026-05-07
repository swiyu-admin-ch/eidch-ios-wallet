import Combine
import Factory
import NavigatorUI
import XCTest
@testable import BITActivity
@testable import BITAnalytics
@testable import BITAnalyticsMocks
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITTestingCore

// MARK: - CredentialDetailViewModelTests

@MainActor
final class CredentialDetailViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    createSuccessState()

    viewModel = CredentialDetailViewModel(mockVerifiableCredential, getActivityHistoryEnabledSubject: getActivityHistoryEnabledSubjectUseCaseSpy)
  }

  func testInitialState() {
    XCTAssertFalse(viewModel.isCredentialDeleted)
    XCTAssertFalse(viewModel.isDeleteCredentialAlertPresented)
    XCTAssertTrue(viewModel.activities.isEmpty)
    XCTAssertEqual(viewModel.credential as? VerifiableCredential, mockVerifiableCredential)
    XCTAssertEqual(getActivityHistoryEnabledSubjectUseCaseSpy.callAsFunctionCallsCount, 1)
  }

  func testOnAppear_withVerifiableCredential_updatesCredentialAndViewModel() async {
    await viewModel.onAppear()

    XCTAssertEqual(viewModel.credential as? VerifiableCredential, updatemockVerifiableCredential)
    XCTAssertEqual(viewModel.credentialViewModel?.credential.id, updatemockVerifiableCredential.id)
    XCTAssertEqual(viewModel.credentialViewModel?.credentialDisplay, credentialDisplayMock)
    XCTAssertEqual(viewModel.activities.map(\.id), activitiesMock.map(\.id))
  }

  func testOnAppear_withDeferredCredential_doNothing() async {
    XCTAssertEqual(getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitCallsCount, 1)
    viewModel = CredentialDetailViewModel(mockDeferredCredential, getActivityHistoryEnabledSubject: getActivityHistoryEnabledSubjectUseCaseSpy)

    await viewModel.onAppear()

    XCTAssertTrue(viewModel.activities.isEmpty)
    XCTAssertFalse(checkAndUpdateCredentialStatusUseCaseSpy.executeForCalled)
    XCTAssertEqual(getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitCallsCount, 1)
  }

  func testOnAppear_withVerifiableCredential_argumentsPassed() async {
    await viewModel.onAppear()

    XCTAssertEqual(getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitReceivedArguments?.credentialId, mockVerifiableCredential.id)
    XCTAssertEqual(getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitReceivedArguments?.limit, 2)
    XCTAssertEqual(checkAndUpdateCredentialStatusUseCaseSpy.executeForReceivedCredential, mockVerifiableCredential)
    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedArguments?.colorScheme, "")
    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedArguments?.displays, updatemockVerifiableCredential.displays)
  }

  func testOnRefresh_withVerifiableCredential_updateCredentials() async {
    await viewModel.refresh()

    XCTAssertEqual(viewModel.credential as? VerifiableCredential, updatemockVerifiableCredential)
    XCTAssertEqual(viewModel.credentialViewModel?.credential.id, updatemockVerifiableCredential.id)
    XCTAssertEqual(viewModel.credentialViewModel?.credentialDisplay, credentialDisplayMock)
  }

  func testOnRefresh_withDeferredCredential_doNothing() async {
    XCTAssertEqual(getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitCallsCount, 1)
    viewModel = CredentialDetailViewModel(mockDeferredCredential, getActivityHistoryEnabledSubject: getActivityHistoryEnabledSubjectUseCaseSpy)

    await viewModel.refresh()

    XCTAssertEqual(getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitCallsCount, 1)
  }

  func testOnRefresh_withVerifiableCredential_argumentsPassed() async {
    await viewModel.refresh()

    XCTAssertEqual(checkAndUpdateCredentialStatusUseCaseSpy.executeForReceivedCredential, mockVerifiableCredential)
    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedArguments?.colorScheme, "")
    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedArguments?.displays, updatemockVerifiableCredential.displays)
  }

  func test_delete_success() async {
    await viewModel.deleteCredential()

    XCTAssertTrue(viewModel.isCredentialDeleted)
    XCTAssertEqual(deleteCredentialUseCaseSpy.executeCallsCount, 1)
    XCTAssertEqual(deleteCredentialUseCaseSpy.executeReceivedCredential?.id, mockVerifiableCredential.id)
  }

  func test_delete_failure() async {
    deleteCredentialUseCaseSpy.executeThrowableError = TestingError.error

    await viewModel.deleteCredential()

    XCTAssertEqual(analyticsProvider.logCounter, 1)
  }

  func testUpdateCredentialViewModel_argumentsPassed() {
    viewModel.updateCredentialViewModel(with: themeMock)

    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedArguments?.colorScheme, themeMock)
    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedArguments?.displays, mockVerifiableCredential.displays)
  }

  func testGetActivityHistoryEnabledSubjectReceive_newValue_setsValueAndFetchesActivities() async {
    XCTAssertEqual(getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitCallsCount, 1)

    subjectMock.send(false)

    try? await Task.sleep(nanoseconds: 1_000_000)

    XCTAssertFalse(viewModel.isActivityHistoryEnabled)
    XCTAssertEqual(getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitCallsCount, 2)
  }

  @MainActor
  func testWillResignActive() async {
    viewModel.isDeleteCredentialAlertPresented = true

    NotificationCenter.default.post(name: UIApplication.willResignActiveNotification, object: nil, userInfo: nil)

    try? await Task.sleep(nanoseconds: 200_000_000)
    XCTAssertFalse(viewModel.isDeleteCredentialAlertPresented)
  }

  // MARK: Private

  // swiftlint:disable all
  private let mockVerifiableCredential = VerifiableCredential.Mock.sample
  private let mockDeferredCredential = DeferredCredential.Mock.sample
  private let updatemockVerifiableCredential = VerifiableCredential.Mock.diploma
  private let credentialDisplayMock = CredentialDisplay.Mock.lightEnglish
  private let activitiesMock: [ActivityListItem] = [.Mock.issuance, .Mock.acceptedPresentation]
  private let themeMock = "light"
  private var subjectMock: CurrentValueSubject<Bool, Never>!
  private var viewModel: CredentialDetailViewModel!

  private var analytics: AnalyticsProtocol!
  private var analyticsProvider: MockProvider!
  private var deleteCredentialUseCaseSpy = DeleteCredentialUseCaseProtocolSpy()
  private var checkAndUpdateCredentialStatusUseCaseSpy = CheckAndUpdateCredentialStatusUseCaseProtocolSpy()
  private var getCredentialDisplayUseCaseSpy = GetCredentialDisplayUseCaseProtocolSpy()
  private var getCredentialActivitiesUseCaseSpy = GetCredentialActivitiesUseCaseProtocolSpy()
  private var getActivityHistoryEnabledSubjectUseCaseSpy = GetActivityHistoryEnabledSubjectUseCaseProtocolSpy()

  // swiftlint:enable all

  private func createSuccessState() {
    checkAndUpdateCredentialStatusUseCaseSpy.executeForReturnValue = updatemockVerifiableCredential
    deleteCredentialUseCaseSpy.executeClosure = { _ in }
    getCredentialDisplayUseCaseSpy.executeForColorSchemeReturnValue = credentialDisplayMock
    getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitReturnValue = activitiesMock
    getActivityHistoryEnabledSubjectUseCaseSpy.callAsFunctionReturnValue = subjectMock
  }

  private func registerMocks() {
    subjectMock = CurrentValueSubject(false)
    analyticsProvider = MockProvider()
    analytics = Analytics()
    analytics.register(analyticsProvider)
    guard let analytics else {
      fatalError("analytics should be initialized in registerMocks")
    }

    Container.shared.analytics.register { @MainActor in analytics }
    Container.shared.deleteCredentialUseCase.register { @MainActor in self.deleteCredentialUseCaseSpy }
    Container.shared.checkAndUpdateCredentialStatusUseCase.register { @MainActor in self.checkAndUpdateCredentialStatusUseCaseSpy }
    Container.shared.getCredentialDisplayUseCase.register { @MainActor in self.getCredentialDisplayUseCaseSpy }
    Container.shared.getCredentialActivitiesUseCase.register { @MainActor in self.getCredentialActivitiesUseCaseSpy }
    Container.shared.getActivityHistoryEnabledSubjectUseCase.register { @MainActor in self.getActivityHistoryEnabledSubjectUseCaseSpy }
  }

}
