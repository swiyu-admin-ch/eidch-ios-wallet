import Factory
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

    viewModel = CredentialDetailViewModel(mockVerifiableCredential, delegate: delegateMock)

    createSuccessState()
  }

  func testInitialState() {
    XCTAssertFalse(viewModel.isCredentialDeleted)
    XCTAssertFalse(viewModel.isDeleteCredentialAlertPresented)
    XCTAssertTrue(viewModel.activities.isEmpty)
    XCTAssertEqual(viewModel.credential as? VerifiableCredential, mockVerifiableCredential)
  }

  func testOnAppear_withVerifiableCredential_updatesCredentialAndViewModel() async {
    await viewModel.onAppear()

    XCTAssertEqual(viewModel.credential as? VerifiableCredential, updatemockVerifiableCredential)
    XCTAssertEqual(viewModel.credentialViewModel?.credential.id, updatemockVerifiableCredential.id)
    XCTAssertEqual(viewModel.credentialViewModel?.credentialDisplay, credentialDisplayMock)
    XCTAssertEqual(viewModel.activities.map(\.activity), activitiesMock)
  }

  func testOnAppear_withDeferredCredential_doNothing() async {
    viewModel = CredentialDetailViewModel(mockDeferredCredential, delegate: delegateMock)

    await viewModel.onAppear()

    XCTAssertTrue(viewModel.activities.isEmpty)
    XCTAssertFalse(checkAndUpdateCredentialStatusUseCaseSpy.executeForCalled)
    XCTAssertFalse(getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitCalled)
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
    viewModel = CredentialDetailViewModel(mockDeferredCredential, delegate: delegateMock)

    await viewModel.refresh()

    XCTAssertFalse(getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitCalled)
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
    XCTAssertTrue(delegateMock.didCallOnCredentialDeleted)
  }

  func test_delete_failure() async {
    deleteCredentialUseCaseSpy.executeThrowableError = TestingError.error

    await viewModel.deleteCredential()

    XCTAssertEqual(analyticsProvider.logCounter, 1)
    XCTAssertFalse(delegateMock.didCallOnCredentialDeleted)
  }

  func testUpdateCredentialViewModel_argumentsPassed() {
    viewModel.updateCredentialViewModel(with: themeMock)

    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedArguments?.colorScheme, themeMock)
    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedArguments?.displays, mockVerifiableCredential.displays)
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
  private let activitiesMock: [Activity] = [.Mock.issueTrusted, .Mock.presentationAcceptedTrusted]
  private let themeMock = "light"
  private var viewModel: CredentialDetailViewModel!
  private let delegateMock = CredentialDetailDelegateMock()

  private var analytics: AnalyticsProtocol!
  private var analyticsProvider: MockProvider!
  private var deleteCredentialUseCaseSpy = DeleteCredentialUseCaseProtocolSpy()
  private var checkAndUpdateCredentialStatusUseCaseSpy = CheckAndUpdateCredentialStatusUseCaseProtocolSpy()
  private var getCredentialDisplayUseCaseSpy = GetCredentialDisplayUseCaseProtocolSpy()
  private var getCredentialActivitiesUseCaseSpy = GetCredentialActivitiesUseCaseProtocolSpy()

  // swiftlint:enable all

  private func createSuccessState() {
    checkAndUpdateCredentialStatusUseCaseSpy.executeForReturnValue = updatemockVerifiableCredential
    deleteCredentialUseCaseSpy.executeClosure = { _ in }
    getCredentialDisplayUseCaseSpy.executeForColorSchemeReturnValue = credentialDisplayMock
    getCredentialActivitiesUseCaseSpy.callAsFunctionForLimitReturnValue = activitiesMock
  }

  private func registerMocks() {
    analyticsProvider = MockProvider()
    analytics = Analytics()
    analytics.register(analyticsProvider)

    Container.shared.analytics.register { self.analytics }
    Container.shared.deleteCredentialUseCase.register { self.deleteCredentialUseCaseSpy }
    Container.shared.checkAndUpdateCredentialStatusUseCase.register { self.checkAndUpdateCredentialStatusUseCaseSpy }
    Container.shared.getCredentialDisplayUseCase.register { self.getCredentialDisplayUseCaseSpy }
    Container.shared.getCredentialActivitiesUseCase.register { self.getCredentialActivitiesUseCaseSpy }
  }

}

// MARK: - CredentialDetailDelegateMock

fileprivate class CredentialDetailDelegateMock: CredentialDetailDelegate {

  var didCallOnCredentialDeleted = false

  func onCredentialDeleted() {
    didCallOnCredentialDeleted = true
  }
}
