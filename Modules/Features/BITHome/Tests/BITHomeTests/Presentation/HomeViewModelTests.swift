import Factory
import XCTest
@testable import BITAppAuth
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITHome
@testable import BITPushNotification
@testable import BITTestingCore

// MARK: - HomeViewModelTests

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try

@MainActor
final class HomeViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    registerMocks()
    viewModel = HomeViewModel()
    createSuccessState()
  }

  func testInitialValues() {
    XCTAssertEqual(viewModel.state, .results)
    XCTAssertNil(viewModel.toast)
    XCTAssertTrue(viewModel.requestCases.isEmpty)
    XCTAssertTrue(viewModel.credentials.isEmpty)
    XCTAssertNil(viewModel.destination)
    XCTAssertNil(viewModel.externalURL)
  }

  // MARK: - onAppear()

  func testOnAppear_everythingEnabled_containResults() async {
    await viewModel.onAppear()

    XCTAssertEqual(getCredentialListUseCase.callAsFunctionCallsCount, 1)
    XCTAssertEqual(refreshCredentialsUseCase.callAsFunctionCallsCount, 1)

    XCTAssertEqual(getEIDRequestCaseListUseCase.callAsFunctionCallsCount, 2)
    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeCallsCount, 1)
    XCTAssertEqual(updatePushTokenUseCase.callAsFunctionCallsCount, 1)

    XCTAssertEqual(viewModel.state, .results)
    XCTAssertEqual(Set(viewModel.credentials.map(\.id)), Set(mockCredentials.map(\.id)))
  }

  func testOnAppear_updatePushTokenFails_silentFails() async {
    updatePushTokenUseCase.callAsFunctionThrowableError = TestingError.error

    await viewModel.onAppear()

    XCTAssertEqual(updatePushTokenUseCase.callAsFunctionCallsCount, 1)
    XCTAssertEqual(getCredentialListUseCase.callAsFunctionCallsCount, 1)
    XCTAssertEqual(getEIDRequestCaseListUseCase.callAsFunctionCallsCount, 2)
    XCTAssertEqual(viewModel.state, .results)
  }

  func testOnAppear_noCredential_stateEmpty() async {
    getCredentialListUseCase.callAsFunctionReturnValue = []
    refreshCredentialsUseCase.callAsFunctionReturnValue = []

    await viewModel.onAppear()

    XCTAssertEqual(viewModel.state, .empty)
    XCTAssertTrue(viewModel.credentials.isEmpty)
  }

  func testOnAppear_credentialThrowError_stateError() async {
    getCredentialListUseCase.callAsFunctionThrowableError = TestingError.error

    await viewModel.onAppear()

    XCTAssertEqual(viewModel.state, .error(TestingError.error))
    XCTAssertTrue(viewModel.credentials.isEmpty)
  }

  func testOnAppear_eIDRequestFeatureNotEnabled_routeToEidRequest() async {
    Container.shared.isEIDRequestFeatureEnabled.register { @MainActor in false }

    await viewModel.onAppear()

    XCTAssertEqual(getCredentialListUseCase.callAsFunctionCallsCount, 1)
    XCTAssertEqual(getEIDRequestCaseListUseCase.callAsFunctionCallsCount, 2)
    XCTAssertEqual(refreshCredentialsUseCase.callAsFunctionCallsCount, 1)

    XCTAssertEqual(viewModel.state, .results)
  }

  func testOnAppear_noEIDRequest_stateResult() async {
    getEIDRequestCaseListUseCase.callAsFunctionReturnValue = []

    await viewModel.onAppear()

    XCTAssertEqual(viewModel.state, .results)
    XCTAssertTrue(viewModel.requestCases.isEmpty)
  }

  func testOnAppear_eidRequestFailure_stateResult() async {
    getEIDRequestCaseListUseCase.callAsFunctionThrowableError = TestingError.error

    await viewModel.onAppear()

    XCTAssertEqual(viewModel.state, .results)
    XCTAssertTrue(viewModel.requestCases.isEmpty)
  }

  func testOnAppear_noData_stateEmpty() async {
    getEIDRequestCaseListUseCase.callAsFunctionReturnValue = []
    getCredentialListUseCase.callAsFunctionReturnValue = []
    refreshCredentialsUseCase.callAsFunctionReturnValue = []

    await viewModel.onAppear()

    XCTAssertEqual(viewModel.state, .empty)
    XCTAssertTrue(viewModel.requestCases.isEmpty)
  }

  // MARK: - Refresh

  func testRefresh_containResults() async {
    await viewModel.refresh()

    XCTAssertEqual(getCredentialListUseCase.callAsFunctionCallsCount, 1)
    XCTAssertEqual(refreshCredentialsUseCase.callAsFunctionCallsCount, 1)

    XCTAssertEqual(getEIDRequestCaseListUseCase.callAsFunctionCallsCount, 2)
    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeCallsCount, 1)

    XCTAssertEqual(viewModel.state, .results)
    XCTAssertEqual(Set(viewModel.credentials.map(\.id)), Set(mockCredentials.map(\.id)))
    XCTAssertEqual(viewModel.requestCases.map(\.id), mockEIDRequestCases.map(\.id))
  }

  func testRefresh_eIDRequestCasesRefreshSucceeds_resetsApplicationBadge() async {
    await viewModel.refresh()

    XCTAssertEqual(resetApplicationBadgeUseCase.callAsFunctionCallsCount, 1)
  }

  func testRefresh_eIDRequestCasesRefreshFails_doesNotResetApplicationBadge() async {
    updateEIDRequestCaseStatusUseCase.executeThrowableError = TestingError.error

    await viewModel.refresh()

    XCTAssertEqual(resetApplicationBadgeUseCase.callAsFunctionCallsCount, 0)
  }

  func testDidLoginRefreshesHome() async {
    await viewModel.didLogin()

    XCTAssertEqual(getCredentialListUseCase.callAsFunctionCallsCount, 1)
    XCTAssertEqual(refreshCredentialsUseCase.callAsFunctionCallsCount, 1)
    XCTAssertEqual(getEIDRequestCaseListUseCase.callAsFunctionCallsCount, 2)
    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeCallsCount, 1)
  }

  func testRefresh_credentialAddedWhileListLoaded_publishesLocalListWithoutWaitingForNetwork() async {
    let initialCredentials: [VerifiableCredential] = [.Mock.sample, .Mock.diploma]
    getCredentialListUseCase.callAsFunctionReturnValue = initialCredentials
    refreshCredentialsUseCase.callAsFunctionReturnValue = initialCredentials

    await viewModel.onAppear()

    XCTAssertEqual(Set(viewModel.credentials.map(\.id)), Set(initialCredentials.map(\.id)))

    getCredentialListUseCase.callAsFunctionReturnValue = mockCredentials
    refreshCredentialsUseCase.callAsFunctionThrowableError = TestingError.error

    await viewModel.refresh()

    XCTAssertEqual(getCredentialListUseCase.callAsFunctionCallsCount, 2)
    XCTAssertEqual(Set(viewModel.credentials.map(\.id)), Set(mockCredentials.map(\.id)))
    XCTAssertEqual(viewModel.state, .results)
  }

  func testFetchData_checkpointAndOnAppearOverlap_coalescesIntoSingleFetch() async {
    let credentials = mockCredentials
    getCredentialListUseCase.callAsFunctionClosure = {
      try? await Task.sleep(nanoseconds: 50_000_000)
      return credentials
    }

    async let onAppear: Void = viewModel.onAppear()
    async let checkpoint: Void = viewModel.handleNavigationCheckpoint(state: .acceptCredential)

    _ = await (onAppear, checkpoint)

    XCTAssertEqual(getCredentialListUseCase.callAsFunctionCallsCount, 1)
    XCTAssertEqual(refreshCredentialsUseCase.callAsFunctionCallsCount, 1)
    XCTAssertEqual(getEIDRequestCaseListUseCase.callAsFunctionCallsCount, 2)
    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeCallsCount, 1)

    XCTAssertNotNil(viewModel.toast)
    XCTAssertEqual(Set(viewModel.credentials.map(\.id)), Set(credentials.map(\.id)))
  }

  func testFetchData_sequentialRefreshes_areNotCoalesced() async {
    await viewModel.refresh()
    await viewModel.refresh()

    XCTAssertEqual(getCredentialListUseCase.callAsFunctionCallsCount, 2)
    XCTAssertEqual(refreshCredentialsUseCase.callAsFunctionCallsCount, 2)
  }

  func testRefresh_afterOnAppear_noData() async {
    await viewModel.onAppear()

    getEIDRequestCaseListUseCase.callAsFunctionReturnValue = []
    getCredentialListUseCase.callAsFunctionReturnValue = []
    refreshCredentialsUseCase.callAsFunctionReturnValue = []

    await viewModel.refresh()

    XCTAssertEqual(getCredentialListUseCase.callAsFunctionCallsCount, 2)
    XCTAssertEqual(refreshCredentialsUseCase.callAsFunctionCallsCount, 2)

    XCTAssertEqual(getEIDRequestCaseListUseCase.callAsFunctionCallsCount, 4)
    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeCallsCount, 2)

    XCTAssertEqual(viewModel.state, .empty)
    XCTAssertTrue(viewModel.credentials.isEmpty)
    XCTAssertTrue(viewModel.requestCases.isEmpty)
  }

  // MARK: - Request case navigation

  func testDidStartAutoVerification() {
    viewModel.didStartAutoVerification(caseId: mockCaseId)

    if case .external(let destination) = viewModel.destination {
      XCTAssertEqual(destination, HomeExternalDestinations.autoVerification(mockCaseId))
    }
  }

  func testDidTapObtainConsent() {
    viewModel.didTapObtainConsent(caseId: mockCaseId)

    if case .external(let destination) = viewModel.destination {
      XCTAssertEqual(destination, HomeExternalDestinations.obtainConsent(mockCaseId))
    }
  }

  func testDidOpenExternalLink() throws {
    let url = try XCTUnwrap(URL(string: "mock_url"))
    viewModel.didOpenExternalLink(url: url)

    XCTAssertEqual(viewModel.externalURL, url)
  }

  func testDidConsumeExternalURL() throws {
    try viewModel.didOpenExternalLink(url: XCTUnwrap(URL(string: "mock_url")))

    viewModel.didConsumeExternalURL()

    XCTAssertNil(viewModel.externalURL)
  }

  func testUpdateCredentialViewModels_argumentsPassed() async {
    let credentialMocks: [VerifiableCredential] = [.Mock.diploma, .Mock.sample]
    getCredentialListUseCase.callAsFunctionReturnValue = credentialMocks
    refreshCredentialsUseCase.callAsFunctionReturnValue = credentialMocks

    await viewModel.onAppear() // set up credentials which will already trigger an updateCredentialViewModels

    viewModel.updateCredentialViewModels(with: themeMock)

    // Closure (not key path): a `\.credential.displays` key path through the existential's associated type crashes SILGen.
    // swiftformat:disable:next preferKeyPath
    let credentialDisplays = viewModel.credentials.map { $0.credential.displays }
    XCTAssertTrue(credentialDisplays.contains(credentialMocks[0].displays))
    XCTAssertTrue(credentialDisplays.contains(credentialMocks[1].displays))
  }

  func testOnAppear_refreshThrowsError_silentFails() async {
    refreshCredentialsUseCase.callAsFunctionThrowableError = TestingError.error

    await viewModel.onAppear()

    XCTAssertEqual(Set(viewModel.credentials.map(\.id)), Set(mockCredentials.map(\.id)))
  }

  func testDidSavedCredential_success() async {
    await viewModel.handleNavigationCheckpoint(state: .acceptCredential)

    XCTAssertNotNil(viewModel.toast)
    assertRefresh()
  }

  func testDidDeclineCredential_success() async {
    await viewModel.handleNavigationCheckpoint(state: .declineCredential)

    XCTAssertNotNil(viewModel.toast)
    assertRefresh()
  }

  func testDidDeleteCredential_success() async {
    await viewModel.handleNavigationCheckpoint(state: .deletedCredential)

    XCTAssertNotNil(viewModel.toast)
    assertRefresh()
  }

  func testDidTapWalletPairing() {
    viewModel.didTapWalletPairing(caseId: mockCaseId)

    if case .external(let destination) = viewModel.destination {
      XCTAssertEqual(destination, HomeExternalDestinations.walletPairing(mockCaseId))
    }
  }

  func testDidTapIdentityCheck() {
    viewModel.didTapIdentityCheck(caseId: mockCaseId)

    if case .external(let destination) = viewModel.destination {
      XCTAssertEqual(destination, HomeExternalDestinations.identityCheck(mockCaseId))
    }
  }

  func testStartRequestCasePolling_callsPollingManager() async {
    await viewModel.handleNavigationCheckpoint(state: .startRequestCasePolling(caseId: mockCaseId))

    XCTAssertEqual(requestCasePollingManager.startPollingForCallsCount, 1)
    XCTAssertEqual(requestCasePollingManager.startPollingForReceivedCaseId, mockCaseId)
    assertRefresh()
  }

  func testStopRefresh_stopsPollingManager() {
    viewModel.stopRefresh()

    XCTAssertEqual(requestCasePollingManager.stopPollingCallsCount, 1)
  }

  func testDidCompletePolling_refreshesRequestCases() async {
    viewModel.didCompletePolling(with: .issuing)

    try? await Task.sleep(nanoseconds: 1_000_000)

    XCTAssertEqual(getEIDRequestCaseListUseCase.callAsFunctionCallsCount, 1)
    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeCallsCount, 1)
  }

  func testNavigationCheckpoint_withoutState_doesRefresh() async {
    await viewModel.handleNavigationCheckpoint(state: nil)

    XCTAssertNil(viewModel.toast)
    XCTAssertEqual(requestCasePollingManager.startPollingForCallsCount, 0)
    assertRefresh()
  }

  // MARK: Private

  private let mockCaseId = "caseId"
  private let mockCredentials = VerifiableCredential.Mock.array
  private let themeMock = "light"
  private var getCredentialListUseCase: GetCredentialListUseCaseProtocolSpy!
  private var refreshCredentialsUseCase: RefreshCredentialsUseCaseProtocolSpy!
  private var deleteEIDRequestCaseUseCase: DeleteEIDRequestCaseUseCaseProtocolSpy!
  private var viewModel: HomeViewModel!
  private var getEIDRequestCaseListUseCase: GetEIDRequestCaseListUseCaseProtocolSpy!
  private var updateEIDRequestCaseStatusUseCase: UpdateEIDRequestCaseStatusUseCaseProtocolSpy!
  private let mockEIDRequestCases: [EIDRequestCase] = [.Mock.sampleInQueue, .Mock.sampleInQueue, .Mock.sampleAVReady]
  private var isUserLoggedInUseCase: IsUserLoggedInUseCaseProtocolSpy!
  private var requestCasePollingManager: RequestCasePollingProtocolSpy!
  private var updatePushTokenUseCase: UpdatePushTokenUseCaseProtocolSpy!
  private var resetApplicationBadgeUseCase: ResetApplicationBadgeUseCaseProtocolSpy!

  private func registerMocks() {
    getCredentialListUseCase = GetCredentialListUseCaseProtocolSpy()
    refreshCredentialsUseCase = RefreshCredentialsUseCaseProtocolSpy()
    getEIDRequestCaseListUseCase = GetEIDRequestCaseListUseCaseProtocolSpy()
    updateEIDRequestCaseStatusUseCase = UpdateEIDRequestCaseStatusUseCaseProtocolSpy()
    deleteEIDRequestCaseUseCase = DeleteEIDRequestCaseUseCaseProtocolSpy()
    isUserLoggedInUseCase = IsUserLoggedInUseCaseProtocolSpy()
    requestCasePollingManager = RequestCasePollingProtocolSpy()
    updatePushTokenUseCase = UpdatePushTokenUseCaseProtocolSpy()
    resetApplicationBadgeUseCase = ResetApplicationBadgeUseCaseProtocolSpy()

    Container.shared.getEIDRequestCaseListUseCase.register { @MainActor in self.getEIDRequestCaseListUseCase }
    Container.shared.updateEIDRequestCaseStatusUseCase.register { @MainActor in self.updateEIDRequestCaseStatusUseCase }
    Container.shared.deleteEIDRequestCaseUseCase.register { @MainActor in self.deleteEIDRequestCaseUseCase }
    Container.shared.isUserLoggedInUseCase.register { @MainActor in self.isUserLoggedInUseCase }
    Container.shared.getCredentialListUseCase.register { @MainActor in self.getCredentialListUseCase }
    Container.shared.refreshCredentialsUseCase.register { @MainActor in self.refreshCredentialsUseCase }
    Container.shared.requestCasePollingManager.register { @MainActor in self.requestCasePollingManager }
    Container.shared.isEIDRequestFeatureEnabled.register { @MainActor in true }
    Container.shared.updatePushTokenUseCase.register { @MainActor in self.updatePushTokenUseCase }
    Container.shared.resetApplicationBadgeUseCase.register { @MainActor in self.resetApplicationBadgeUseCase }
  }

  private func createSuccessState() {
    isUserLoggedInUseCase.callAsFunctionReturnValue = true
    getCredentialListUseCase.callAsFunctionReturnValue = mockCredentials
    getEIDRequestCaseListUseCase.callAsFunctionReturnValue = mockEIDRequestCases
    refreshCredentialsUseCase.callAsFunctionReturnValue = mockCredentials
  }

  private func assertRefresh() {
    XCTAssertEqual(getCredentialListUseCase.callAsFunctionCallsCount, 1)
    XCTAssertEqual(viewModel.state, .results)
    XCTAssertEqual(refreshCredentialsUseCase?.callAsFunctionCallsCount, 1)
    XCTAssertEqual(getEIDRequestCaseListUseCase?.callAsFunctionCallsCount, 2)
    XCTAssertEqual(updateEIDRequestCaseStatusUseCase?.executeCallsCount, 1)
    XCTAssertEqual(updatePushTokenUseCase?.callAsFunctionCallsCount, 1)
  }
}

// MARK: - HomeViewModel.State + Equatable

extension HomeViewModel.State: Equatable {
  public static func == (lhs: HomeViewModel.State, rhs: HomeViewModel.State) -> Bool {
    switch (lhs, rhs) {
    case (.empty, .empty):
      true
    case (.results, .results):
      true
    case (.error(let lhsError), .error(let rhsError)):
      lhsError.localizedDescription == rhsError.localizedDescription
    default:
      false
    }
  }
}
