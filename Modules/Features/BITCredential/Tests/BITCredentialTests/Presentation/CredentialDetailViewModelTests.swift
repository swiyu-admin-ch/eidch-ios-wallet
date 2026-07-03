import Combine
import Factory
import NavigatorUI
import XCTest
@testable import BITActivity
@testable import BITAnalytics
@testable import BITAnalyticsMocks
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITL10n
@testable import BITTestingCore
@testable import BITTheming

// MARK: - CredentialDetailViewModelTests

@MainActor
final class CredentialDetailViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    createSuccessState()

    viewModel = CredentialDetailViewModel(mockVerifiableCredential.id, getActivityHistoryEnabledSubject: getActivityHistoryEnabledSubjectUseCaseSpy)
  }

  func testInitialState() {
    XCTAssertFalse(viewModel.isCredentialDeleted)
    XCTAssertFalse(viewModel.isDeleteCredentialAlertPresented)
    XCTAssertTrue(viewModel.isLoading)
    XCTAssertTrue(viewModel.activities.isEmpty)
    XCTAssertNil(viewModel.credential)
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
    getCredentialUseCaseSpy.callAsFunctionIdReturnValue = mockDeferredCredential
    viewModel = CredentialDetailViewModel(mockDeferredCredential.id, getActivityHistoryEnabledSubject: getActivityHistoryEnabledSubjectUseCaseSpy)

    await viewModel.onAppear()

    XCTAssertTrue(viewModel.activities.isEmpty)
    XCTAssertFalse(checkAndUpdateCredentialStatusUseCaseSpy.executeForCalled)
    XCTAssertEqual(getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitCallsCount, 0)
  }

  func testOnAppear_withVerifiableCredential_argumentsPassed() async {
    await viewModel.onAppear()

    XCTAssertEqual(getCredentialUseCaseSpy.callAsFunctionIdReceivedId, mockVerifiableCredential.id)
    XCTAssertEqual(getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitReceivedArguments?.credentialId, mockVerifiableCredential.id)
    XCTAssertEqual(getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitReceivedArguments?.limit, 2)
    XCTAssertEqual(checkAndUpdateCredentialStatusUseCaseSpy.executeForReceivedCredential, mockVerifiableCredential)
    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedArguments?.colorScheme, "")
    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedArguments?.displays, updatemockVerifiableCredential.displays)
  }

  func testOnAppear_refreshesCredentialFromDatabaseBeforeUpdatingStatus() async {
    getCredentialUseCaseSpy.callAsFunctionIdReturnValue = updatemockVerifiableCredential
    checkAndUpdateCredentialStatusUseCaseSpy.executeForReturnValue = updatemockVerifiableCredential

    await viewModel.onAppear()

    XCTAssertEqual(getCredentialUseCaseSpy.callAsFunctionIdCallsCount, 1)
    XCTAssertEqual(getCredentialUseCaseSpy.callAsFunctionIdReceivedId, mockVerifiableCredential.id)
    XCTAssertEqual(checkAndUpdateCredentialStatusUseCaseSpy.executeForReceivedCredential, updatemockVerifiableCredential)
    XCTAssertEqual(viewModel.credential as? VerifiableCredential, updatemockVerifiableCredential)
  }

  func testOnRefresh_withVerifiableCredential_updateCredentials() async {
    await viewModel.onAppear()

    await viewModel.refresh()

    XCTAssertEqual(viewModel.credential as? VerifiableCredential, updatemockVerifiableCredential)
    XCTAssertEqual(viewModel.credentialViewModel?.credential.id, updatemockVerifiableCredential.id)
    XCTAssertEqual(viewModel.credentialViewModel?.credentialDisplay, credentialDisplayMock)
  }

  func testOnRefresh_withDeferredCredential_doNothing() async {
    getCredentialUseCaseSpy.callAsFunctionIdReturnValue = mockDeferredCredential
    viewModel = CredentialDetailViewModel(mockDeferredCredential.id, getActivityHistoryEnabledSubject: getActivityHistoryEnabledSubjectUseCaseSpy)
    await viewModel.onAppear()

    await viewModel.refresh()

    XCTAssertEqual(getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitCallsCount, 0)
  }

  func testOnRefresh_withVerifiableCredential_argumentsPassed() async {
    await viewModel.onAppear()

    await viewModel.refresh()

    XCTAssertEqual(checkAndUpdateCredentialStatusUseCaseSpy.executeForReceivedCredential, updatemockVerifiableCredential)
    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedArguments?.colorScheme, "")
    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedArguments?.displays, updatemockVerifiableCredential.displays)
  }

  func test_delete_success() async {
    await viewModel.onAppear()

    await viewModel.deleteCredential()

    XCTAssertTrue(viewModel.isCredentialDeleted)
    XCTAssertEqual(deleteCredentialUseCaseSpy.executeCallsCount, 1)
    XCTAssertEqual(deleteCredentialUseCaseSpy.executeReceivedCredential?.id, updatemockVerifiableCredential.id)
  }

  func test_delete_failure() async {
    await viewModel.onAppear()
    deleteCredentialUseCaseSpy.executeThrowableError = TestingError.error

    await viewModel.deleteCredential()

    XCTAssertEqual(analyticsProvider.logCounter, 1)
  }

  func testHandleCredentialRefreshed_updatesCredentialAndShowsToast() {
    viewModel.handleCredentialRefreshed(updatemockVerifiableCredential)

    XCTAssertEqual(viewModel.credential as? VerifiableCredential, updatemockVerifiableCredential)
    XCTAssertEqual(viewModel.toast, Toast(L10n.tkDisplayrefreshNotificationSuccess))
  }

  func testBatchPrivacyWarningVisible_withExhaustedBatchCredential_returnsTrue() {
    let exhaustedBatchCredential = makeBatchCredential(allBundleItemsPresented: true)

    viewModel.credential = exhaustedBatchCredential

    XCTAssertTrue(viewModel.isBatchPrivacyWarningVisible)
  }

  func testBatchPrivacyWarningVisible_withRemainingUnpresentedBundleItem_returnsFalse() {
    let batchCredential = makeBatchCredential(allBundleItemsPresented: false)

    viewModel.credential = batchCredential

    XCTAssertFalse(viewModel.isBatchPrivacyWarningVisible)
  }

  func testBatchPrivacyWarningVisible_withoutBatchesWithUnpresentedBundleItem_returnsFalse() {
    viewModel.credential = mockVerifiableCredential

    XCTAssertFalse(viewModel.isBatchPrivacyWarningVisible)
  }

  func testBatchPrivacyWarningVisible_withoutBatchesWithPresentedBundleItem_returnsFalse() {
    var credential = mockVerifiableCredential
    credential.bundleItems = credential.bundleItems.map {
      var item = $0
      item.presented = true
      return item
    }
    viewModel.credential = credential

    XCTAssertFalse(viewModel.isBatchPrivacyWarningVisible)
  }

  func testRefreshBatchCredential_success_updatesCredentialAndShowsToast() async {
    let exhaustedBatchCredential = makeBatchCredential(allBundleItemsPresented: true)
    refreshCredentialUseCaseSpy.callAsFunctionReturnValue = updatemockVerifiableCredential
    viewModel.credential = exhaustedBatchCredential

    await viewModel.refreshBatchCredential()

    XCTAssertEqual(refreshCredentialUseCaseSpy.callAsFunctionCallsCount, 1)
    XCTAssertEqual(refreshCredentialUseCaseSpy.callAsFunctionReceivedCredential, exhaustedBatchCredential)
    XCTAssertEqual(viewModel.credential as? VerifiableCredential, updatemockVerifiableCredential)
    XCTAssertEqual(viewModel.toast, Toast(L10n.tkDisplayrefreshNotificationSuccess))
    XCTAssertFalse(viewModel.isRefreshLoading)
    XCTAssertFalse(viewModel.isRefreshErrorPresented)
  }

  func testRefreshBatchCredential_failure_showsErrorNotification() async {
    let exhaustedBatchCredential = makeBatchCredential(allBundleItemsPresented: true)
    refreshCredentialUseCaseSpy.callAsFunctionThrowableError = TestingError.error
    viewModel.credential = exhaustedBatchCredential

    await viewModel.refreshBatchCredential()

    XCTAssertEqual(refreshCredentialUseCaseSpy.callAsFunctionCallsCount, 1)
    XCTAssertTrue(viewModel.isRefreshErrorPresented)
    XCTAssertFalse(viewModel.isRefreshLoading)
    XCTAssertEqual(analyticsProvider.logCounter, 1)
  }

  func testUpdateCredentialViewModel_argumentsPassed() {
    viewModel.credential = mockVerifiableCredential

    viewModel.updateCredentialViewModel(with: themeMock)

    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedArguments?.colorScheme, themeMock)
    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedArguments?.displays, mockVerifiableCredential.displays)
  }

  func testGetActivityHistoryEnabledSubjectReceive_newValue_setsValueAndFetchesActivities() async {
    await viewModel.onAppear()
    XCTAssertEqual(getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitCallsCount, 1)

    subjectMock.send(false)

    try? await Task.sleep(nanoseconds: 1_000_000)

    XCTAssertFalse(viewModel.isActivityHistoryEnabled)
    XCTAssertEqual(getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitCallsCount, 2)
  }

  @MainActor
  func testWillResignActive_resetsDeleteAlert() async {
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
  private var getCredentialUseCaseSpy = GetCredentialUseCaseProtocolSpy()
  private var refreshCredentialUseCaseSpy = RefreshVerifiableCredentialUseCaseProtocolSpy()
  private var getCredentialDisplayUseCaseSpy = GetCredentialDisplayUseCaseProtocolSpy()
  private var getCredentialActivitiesUseCaseSpy = GetCredentialActivitiesUseCaseProtocolSpy()
  private var getActivityHistoryEnabledSubjectUseCaseSpy = GetActivityHistoryEnabledSubjectUseCaseProtocolSpy()

  // swiftlint:enable all

  private func createSuccessState() {
    getCredentialUseCaseSpy.callAsFunctionIdReturnValue = mockVerifiableCredential
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

    Container.shared.isBatchIssuanceEnabled.register { true }
    Container.shared.analytics.register { @MainActor in analytics }
    Container.shared.deleteCredentialUseCase.register { @MainActor in self.deleteCredentialUseCaseSpy }
    Container.shared.checkAndUpdateCredentialStatusUseCase.register { @MainActor in self.checkAndUpdateCredentialStatusUseCaseSpy }
    Container.shared.getCredentialUseCase.register { @MainActor in self.getCredentialUseCaseSpy }
    Container.shared.refreshCredentialUseCase.register { @MainActor in self.refreshCredentialUseCaseSpy }
    Container.shared.getCredentialDisplayUseCase.register { @MainActor in self.getCredentialDisplayUseCaseSpy }
    Container.shared.getCredentialActivitiesUseCase.register { @MainActor in self.getCredentialActivitiesUseCaseSpy }
    Container.shared.getActivityHistoryEnabledSubjectUseCase.register { @MainActor in self.getActivityHistoryEnabledSubjectUseCaseSpy }
  }

  private func makeBatchCredential(allBundleItemsPresented: Bool) -> VerifiableCredential {
    var credential = mockVerifiableCredential
    credential.batchData = BatchData(batchSize: 2)
    credential.authentication = CredentialAuthentication(
      accessToken: credential.authentication.accessToken,
      tokenType: credential.authentication.tokenType,
      refreshToken: "refresh-token",
      dpopBinding: credential.authentication.dpopBinding)

    if credential.bundleItems.count == 1 {
      credential.bundleItems.append(BundleItem(payload: Data("second".utf8)))
    }

    credential.bundleItems = credential.bundleItems.enumerated().map { index, item in
      var item = item
      item.presented = allBundleItemsPresented || index == 0
      return item
    }
    credential.nextPresentableBundleItemId = credential.bundleItems.last?.id ?? credential.nextPresentableBundleItemId
    return credential
  }

}
