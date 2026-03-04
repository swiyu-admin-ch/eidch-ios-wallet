import Factory
import XCTest
@testable import BITAppAuth
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITHome
@testable import BITTestingCore

// MARK: - HomeViewModelTests

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try

@MainActor
final class HomeViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    registerMocks()
    mockRouter = HomeRouterMock()
    viewModel = HomeViewModel(router: mockRouter)
    createSuccesState()
  }

  func testInitialValues() {
    XCTAssertEqual(viewModel.state, .results)
    XCTAssertFalse(viewModel.isToastPresented)
    XCTAssertTrue(viewModel.requestCases.isEmpty)
    XCTAssertTrue(viewModel.credentials.isEmpty)
  }

  // MARK: - onAppear()

  func testOnAppear_everythingEnabled_containResults() async {
    await viewModel.onAppear()

    XCTAssertEqual(enableEIDRequestAfterOnboardingUseCase.executeReceivedEnable, false)

    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 1)
    XCTAssertEqual(refreshCredentialsUseCase.callAsFunctionCallsCount, 1)

    XCTAssertEqual(getEIDRequestCaseListUseCase.executeCallsCount, 2)
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
    Container.shared.isEIDRequestFeatureEnabled.register { false }

    await viewModel.onAppear()

    XCTAssertTrue(mockRouter.didCallEIDRequest)
    XCTAssertTrue(enableEIDRequestAfterOnboardingUseCase.executeCalled)

    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 1)
    XCTAssertEqual(getEIDRequestCaseListUseCase.executeCallsCount, 2)
    XCTAssertEqual(refreshCredentialsUseCase.callAsFunctionCallsCount, 1)

    XCTAssertEqual(viewModel.state, .results)
  }

  func testOnAppear_noEIDRequest_stateResult() async {
    getEIDRequestCaseListUseCase.executeReturnValue = []

    await viewModel.onAppear()

    XCTAssertEqual(viewModel.state, .results)
    XCTAssertTrue(viewModel.requestCases.isEmpty)
  }

  func testOnAppear_eidRequestFailure_stateResult() async {
    getEIDRequestCaseListUseCase.executeThrowableError = TestingError.error

    await viewModel.onAppear()

    XCTAssertEqual(viewModel.state, .results)
    XCTAssertTrue(viewModel.requestCases.isEmpty)
  }

  func testOnAppear_noData_stateEmpty() async {
    getEIDRequestCaseListUseCase.executeReturnValue = []
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

    XCTAssertEqual(getEIDRequestCaseListUseCase.executeCallsCount, 2)
    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeCallsCount, 1)

    XCTAssertEqual(viewModel.state, .results)
    XCTAssertEqual(viewModel.credentials.map(\.id), mockCrendentials.map(\.id))
    XCTAssertEqual(viewModel.requestCases.map(\.id), mockEIDRequestCases.map(\.id))
  }

  func testRefresh_afterOnAppear_noData() async {
    await viewModel.onAppear()

    getEIDRequestCaseListUseCase.executeReturnValue = []
    getCredentialListUseCase.executeReturnValue = []
    refreshCredentialsUseCase.callAsFunctionReturnValue = []

    await viewModel.refresh()

    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 2)
    XCTAssertEqual(refreshCredentialsUseCase.callAsFunctionCallsCount, 2)

    XCTAssertEqual(getEIDRequestCaseListUseCase.executeCallsCount, 4)
    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeCallsCount, 2)

    XCTAssertEqual(viewModel.state, .empty)
    XCTAssertTrue(viewModel.credentials.isEmpty)
    XCTAssertTrue(viewModel.requestCases.isEmpty)
  }

  // MARK: - Navigation

  func testOpenScanner() {
    viewModel.openScanner()

    XCTAssertTrue(mockRouter.didCallInvitation)
  }

  func testOpenSettings() {
    viewModel.openSettings()

    XCTAssertTrue(mockRouter.didCallSettings)
  }

  func testOpenHelp() {
    viewModel.openHelp()

    XCTAssertTrue(mockRouter.didCallExternalLinkUrl)
  }

  func testOpenCredential_deferredCredential_routeToDetails() {
    viewModel.openCredential(DeferredCredentialViewModel(credential: .Mock.sample))

    XCTAssertTrue(mockRouter.didCallOpenCredentialDetail)
  }

  func testOpenCredential_unacceptedCredential_routeToOffer() {
    viewModel.openCredential(VerifiableCredentialViewModel(credential: VerifiableCredential(progressionState: .unaccepted, payload: Data(), format: "format", issuerUrl: "issuerUrl", issuer: "issuer")))

    XCTAssertTrue(mockRouter.didCallCredentialOffer)
  }

  func testOpenCredential_acceptedCredential_routeToDetails() {
    viewModel.openCredential(VerifiableCredentialViewModel(credential: .Mock.sample))

    XCTAssertTrue(mockRouter.didCallOpenCredentialDetail)
  }

  func testOpenBetaId() {
    viewModel.openBetaId()

    XCTAssertTrue(mockRouter.didCallBetaId)
  }

  func testOpenEIDRequest() {
    viewModel.openEIDRequest()

    XCTAssertTrue(mockRouter.didCallEIDRequest)
  }

  func testDidStartAutoVerification() {
    viewModel.didStartAutoVerification(caseId: mockCaseId)

    XCTAssertEqual(mockRouter.didCallAutoVerificationArgument, mockCaseId)
  }

  func testDidTapObtainConsent() {
    viewModel.didTapObtainConsent(caseId: mockCaseId)

    XCTAssertEqual(mockRouter.didCallObtainConsentArgument, mockCaseId)
  }

  func testDidOpenExternalLink() throws {
    try viewModel.didOpenExternalLink(url: XCTUnwrap(URL(string: "mock_url")))

    XCTAssertEqual(mockRouter.didCallExternalLinkUrl, true)
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

    XCTAssertTrue(viewModel.isToastPresented)
  }

  func testDidDeclineCredential_success() {
    viewModel.didDeclineCredential()

    XCTAssertTrue(viewModel.isToastPresented)
  }

  func testOnCredentialDeleted_success() {
    viewModel.onCredentialDeleted()

    XCTAssertTrue(viewModel.isToastPresented)
  }

  func testClearToast_toastIsHidden() {
    viewModel.onCredentialDeleted()
    XCTAssertNotNil(viewModel.toastMessage)
    XCTAssertTrue(viewModel.isToastPresented)

    viewModel.clearToast()

    XCTAssertNil(viewModel.toastMessage)
    XCTAssertFalse(viewModel.isToastPresented)
  }

  func testDidTapWalletPairing() {
    viewModel.didTapWalletPairing(caseId: mockCaseId)

    XCTAssertEqual(mockRouter.didCallWalletPairingArgument, mockCaseId)
  }

  func testDidTapIdentityCheck() {
    viewModel.didTapIdentityCheck(caseId: mockCaseId)

    XCTAssertEqual(mockRouter.didCallIdentityCheckArgument, mockCaseId)
  }

  // MARK: Private

  private let mockCaseId = "caseId"
  private let mockCrendentials = VerifiableCredential.Mock.array
  private let themeMock = "light"
  private var getCredentialListUseCase: GetCredentialListUseCaseProtocolSpy!
  private var refreshCredentialsUseCase: RefreshCredentialsUseCaseProtocolSpy!
  private var isEIDRequestAfterOnboardingEnabledUseCase: IsEIDRequestAfterOnboardingEnabledUseCaseProtocolSpy!
  private var enableEIDRequestAfterOnboardingUseCase: EnableEIDRequestAfterOnboardingUseCaseProtocolSpy!
  private var deleteEIDRequestCaseUseCase: DeleteEIDRequestCaseUseCaseProtocolSpy!
  private var viewModel: HomeViewModel!
  private var mockRouter: HomeRouterMock!
  private var getEIDRequestCaseListUseCase: GetEIDRequestCaseListUseCaseProtocolSpy!
  private var updateEIDRequestCaseStatusUseCase: UpdateEIDRequestCaseStatusUseCaseProtocolSpy!
  private var mockEIDRequestCases: [EIDRequestCase] = [.Mock.sampleInQueue, .Mock.sampleInQueue, .Mock.sampleAVReady]
  private var isUserLoggedInUseCase: IsUserLoggedInUseCaseProtocolSpy!

  private func registerMocks() {
    getCredentialListUseCase = GetCredentialListUseCaseProtocolSpy()
    refreshCredentialsUseCase = RefreshCredentialsUseCaseProtocolSpy()
    isEIDRequestAfterOnboardingEnabledUseCase = IsEIDRequestAfterOnboardingEnabledUseCaseProtocolSpy()
    enableEIDRequestAfterOnboardingUseCase = EnableEIDRequestAfterOnboardingUseCaseProtocolSpy()
    getEIDRequestCaseListUseCase = GetEIDRequestCaseListUseCaseProtocolSpy()
    updateEIDRequestCaseStatusUseCase = UpdateEIDRequestCaseStatusUseCaseProtocolSpy()
    deleteEIDRequestCaseUseCase = DeleteEIDRequestCaseUseCaseProtocolSpy()
    isUserLoggedInUseCase = IsUserLoggedInUseCaseProtocolSpy()

    Container.shared.getEIDRequestCaseListUseCase.register { self.getEIDRequestCaseListUseCase }
    Container.shared.updateEIDRequestCaseStatusUseCase.register { self.updateEIDRequestCaseStatusUseCase }
    Container.shared.deleteEIDRequestCaseUseCase.register { self.deleteEIDRequestCaseUseCase }
    Container.shared.isUserLoggedInUseCase.register { self.isUserLoggedInUseCase }
    Container.shared.getCredentialListUseCase.register { self.getCredentialListUseCase }
    Container.shared.refreshCredentialsUseCase.register { self.refreshCredentialsUseCase }
    Container.shared.isEIDRequestAfterOnboardingEnabledUseCase.register { self.isEIDRequestAfterOnboardingEnabledUseCase }
    Container.shared.enableEIDRequestAfterOnboardingUseCase.register { self.enableEIDRequestAfterOnboardingUseCase }
    Container.shared.isEIDRequestFeatureEnabled.register { true }
  }

  private func createSuccesState() {
    isEIDRequestAfterOnboardingEnabledUseCase.executeReturnValue = true
    isUserLoggedInUseCase.executeReturnValue = true
    getCredentialListUseCase.executeReturnValue = mockCrendentials
    getEIDRequestCaseListUseCase.executeReturnValue = mockEIDRequestCases
    refreshCredentialsUseCase.callAsFunctionReturnValue = mockCrendentials
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
