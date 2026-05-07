import Factory
import XCTest
@testable import BITAppAuth
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITHome
@testable import BITInvitation
@testable import BITOTP
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
    createSuccesState()
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

    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 1)
    XCTAssertEqual(refreshCredentialsUseCase.callAsFunctionCallsCount, 1)

    XCTAssertEqual(getEIDRequestCaseListUseCase.callAsFunctionCallsCount, 2)
    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeCallsCount, 1)

    XCTAssertEqual(viewModel.state, .results)
    XCTAssertEqual(viewModel.credentials.map(\.id), mockCrendentials.map(\.id))
    XCTAssertEqual(viewModel.requestCases.map(\.id), mockEIDRequestCases.map(\.id))
  }

  func testOnAppear_noCredential_stateEmpty() async {
    getCredentialListUseCase.executeReturnValue = []
    refreshCredentialsUseCase.callAsFunctionReturnValue = []

    await viewModel.onAppear()

    XCTAssertEqual(viewModel.state, .empty)
    XCTAssertTrue(viewModel.credentials.isEmpty)
  }

  func testOnAppear_credentialThrowError_stateError() async {
    getCredentialListUseCase.executeThrowableError = TestingError.error

    await viewModel.onAppear()

    XCTAssertEqual(viewModel.state, .error(TestingError.error))
    XCTAssertTrue(viewModel.credentials.isEmpty)
  }

  func testOnAppear_eIDRequestFeatureNotEnabled_routeToEidRequest() async {
    Container.shared.isEIDRequestFeatureEnabled.register { @MainActor in false }

    await viewModel.onAppear()

    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 1)
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
    getCredentialListUseCase.executeReturnValue = []
    refreshCredentialsUseCase.callAsFunctionReturnValue = []

    await viewModel.onAppear()

    XCTAssertEqual(viewModel.state, .empty)
    XCTAssertTrue(viewModel.requestCases.isEmpty)
  }

  // MARK: - Refresh

  func testRefresh_containResults() async {
    await viewModel.refresh()

    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 1)
    XCTAssertEqual(refreshCredentialsUseCase.callAsFunctionCallsCount, 1)

    XCTAssertEqual(getEIDRequestCaseListUseCase.callAsFunctionCallsCount, 2)
    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeCallsCount, 1)

    XCTAssertEqual(viewModel.state, .results)
    XCTAssertEqual(viewModel.credentials.map(\.id), mockCrendentials.map(\.id))
    XCTAssertEqual(viewModel.requestCases.map(\.id), mockEIDRequestCases.map(\.id))
  }

  func testRefresh_afterOnAppear_noData() async {
    await viewModel.onAppear()

    getEIDRequestCaseListUseCase.callAsFunctionReturnValue = []
    getCredentialListUseCase.executeReturnValue = []
    refreshCredentialsUseCase.callAsFunctionReturnValue = []

    await viewModel.refresh()

    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 2)
    XCTAssertEqual(refreshCredentialsUseCase.callAsFunctionCallsCount, 2)

    XCTAssertEqual(getEIDRequestCaseListUseCase.callAsFunctionCallsCount, 4)
    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeCallsCount, 2)

    XCTAssertEqual(viewModel.state, .empty)
    XCTAssertTrue(viewModel.credentials.isEmpty)
    XCTAssertTrue(viewModel.requestCases.isEmpty)
  }

  // MARK: - Navigation

  func testOpenScanner() {
    viewModel.openScanner()

    if case .external(let destination) = viewModel.destination {
      XCTAssertEqual(destination, HomeExternalDestinations.invitation(.scan))
    }
  }

  func testOpenSettings() {
    viewModel.openSettings()

    if case .external(let destination) = viewModel.destination {
      XCTAssertEqual(destination, HomeExternalDestinations.settings)
    }
  }

  func testOpenCredential_deferredCredential_routeToDetails() {
    viewModel.openCredential(DeferredCredentialViewModel(credential: .Mock.sample))

    guard
      case .external(let destination) = viewModel.destination,
      case .credentialDetail(let input) = destination else
    {
      return XCTFail("Expected credential detail destination")
    }

    XCTAssertEqual(input.credential.id, DeferredCredential.Mock.sample.id)
  }

  func testOpenCredential_unacceptedCredential_routeToOffer() {
    let credentialViewModel = VerifiableCredentialViewModel(
      credential: VerifiableCredential(
        progressionState: .unaccepted,
        bundleItems: [BundleItem(payload: Data())],
        nextPresentableBundleItemId: UUID(),
        format: "format",
        issuerUrl: "issuerUrl",
        issuer: "issuer",
        authentication: CredentialAuthentication(accessToken: "accessToken")))

    viewModel.openCredential(credentialViewModel)

    if case .external(let destination) = viewModel.destination {
      XCTAssertEqual(destination, HomeExternalDestinations.offer(credentialViewModel.credential, nil))
    }
  }

  func testOpenCredential_acceptedCredential_routeToDetails() {
    viewModel.openCredential(VerifiableCredentialViewModel(credential: .Mock.sample))

    guard
      case .external(let destination) = viewModel.destination,
      case .credentialDetail(let input) = destination else
    {
      return XCTFail("Expected credential detail destination")
    }

    XCTAssertEqual(input.credential.id, VerifiableCredential.Mock.sample.id)
  }

  func testOpenBetaId() {
    viewModel.openBetaId()

    if case .external(let destination) = viewModel.destination {
      XCTAssertEqual(destination, HomeExternalDestinations.betaId)
    }
  }

  func testOpenEIDRequest() {
    viewModel.openEIDRequest()

    if case .external(let destination) = viewModel.destination {
      XCTAssertEqual(destination, HomeExternalDestinations.otp)
    }

    XCTAssertEqual(isOTPEnabledUseCase.callAsFunctionCallsCount, 1)
  }

  func testOpenEIDRequest_whenOTPDisabled_routesToEIDRequest() {
    isOTPEnabledUseCase.callAsFunctionReturnValue = false

    viewModel.openEIDRequest()

    if case .external(let destination) = viewModel.destination {
      XCTAssertEqual(destination, HomeExternalDestinations.eIDRequest)
    }

    XCTAssertEqual(isOTPEnabledUseCase.callAsFunctionCallsCount, 1)
  }

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
    getCredentialListUseCase.executeReturnValue = credentialMocks
    refreshCredentialsUseCase.callAsFunctionReturnValue = credentialMocks

    await viewModel.onAppear() // set up credentials which will already trigger an updateCredentialViewModels

    viewModel.updateCredentialViewModels(with: themeMock)

    XCTAssertEqual(viewModel.credentials[0].credential.displays, credentialMocks[0].displays)
    XCTAssertEqual(viewModel.credentials[1].credential.displays, credentialMocks[1].displays)
  }

  func testOnAppear_refreshThrowsError_silentFails() async {
    refreshCredentialsUseCase.callAsFunctionThrowableError = TestingError.error

    await viewModel.onAppear()

    XCTAssertEqual(viewModel.credentials.map(\.id), mockCrendentials.map(\.id))
  }

  func testDidSavedCredential_success() {
    viewModel.didSaveCredential()

    XCTAssertNotNil(viewModel.toast)
  }

  func testDidDeclineCredential_success() {
    viewModel.didDeclineCredential()

    XCTAssertNotNil(viewModel.toast)
  }

  func testDidDeleteCredential_success() {
    viewModel.didDeleteCredential()

    XCTAssertNotNil(viewModel.toast)
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

  func testStartRequestCasePolling_callsPollingManager() {
    viewModel.startRequestCasePolling(for: mockCaseId)

    XCTAssertEqual(requestCasePollingManager.startPollingForCallsCount, 1)
    XCTAssertEqual(requestCasePollingManager.startPollingForReceivedCaseId, mockCaseId)
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

  // MARK: Private

  private let mockCaseId = "caseId"
  private let mockCrendentials = VerifiableCredential.Mock.array
  private let themeMock = "light"
  private var getCredentialListUseCase: GetCredentialListUseCaseProtocolSpy!
  private var refreshCredentialsUseCase: RefreshCredentialsUseCaseProtocolSpy!
  private var deleteEIDRequestCaseUseCase: DeleteEIDRequestCaseUseCaseProtocolSpy!
  private var viewModel: HomeViewModel!
  private var getEIDRequestCaseListUseCase: GetEIDRequestCaseListUseCaseProtocolSpy!
  private var updateEIDRequestCaseStatusUseCase: UpdateEIDRequestCaseStatusUseCaseProtocolSpy!
  private var mockEIDRequestCases: [EIDRequestCase] = [.Mock.sampleInQueue, .Mock.sampleInQueue, .Mock.sampleAVReady]
  private var isUserLoggedInUseCase: IsUserLoggedInUseCaseProtocolSpy!
  private var isOTPEnabledUseCase: IsOTPEnabledUseCaseProtocolSpy!
  private var requestCasePollingManager: RequestCasePollingProtocolSpy!

  private func registerMocks() {
    getCredentialListUseCase = GetCredentialListUseCaseProtocolSpy()
    refreshCredentialsUseCase = RefreshCredentialsUseCaseProtocolSpy()
    getEIDRequestCaseListUseCase = GetEIDRequestCaseListUseCaseProtocolSpy()
    updateEIDRequestCaseStatusUseCase = UpdateEIDRequestCaseStatusUseCaseProtocolSpy()
    deleteEIDRequestCaseUseCase = DeleteEIDRequestCaseUseCaseProtocolSpy()
    isUserLoggedInUseCase = IsUserLoggedInUseCaseProtocolSpy()
    isOTPEnabledUseCase = IsOTPEnabledUseCaseProtocolSpy()
    requestCasePollingManager = RequestCasePollingProtocolSpy()

    Container.shared.getEIDRequestCaseListUseCase.register { @MainActor in self.getEIDRequestCaseListUseCase }
    Container.shared.updateEIDRequestCaseStatusUseCase.register { @MainActor in self.updateEIDRequestCaseStatusUseCase }
    Container.shared.deleteEIDRequestCaseUseCase.register { @MainActor in self.deleteEIDRequestCaseUseCase }
    Container.shared.isUserLoggedInUseCase.register { @MainActor in self.isUserLoggedInUseCase }
    Container.shared.getCredentialListUseCase.register { @MainActor in self.getCredentialListUseCase }
    Container.shared.refreshCredentialsUseCase.register { @MainActor in self.refreshCredentialsUseCase }
    Container.shared.requestCasePollingManager.register { @MainActor in self.requestCasePollingManager }
    Container.shared.isEIDRequestFeatureEnabled.register { @MainActor in true }
    Container.shared.isOTPEnabledUseCase.register { @MainActor in self.isOTPEnabledUseCase }
  }

  private func createSuccesState() {
    isUserLoggedInUseCase.executeReturnValue = true
    getCredentialListUseCase.executeReturnValue = mockCrendentials
    getEIDRequestCaseListUseCase.callAsFunctionReturnValue = mockEIDRequestCases
    refreshCredentialsUseCase.callAsFunctionReturnValue = mockCrendentials
    isOTPEnabledUseCase.callAsFunctionReturnValue = true
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
