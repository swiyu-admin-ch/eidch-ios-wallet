import Factory
import XCTest
@testable import BITAppAuth
@testable import BITCredential
@testable import BITCredentialMocks
@testable import BITCredentialShared
@testable import BITEIDRequest
@testable import BITHome
@testable import BITTestingCore

final class HomeViewModelTests: XCTestCase {

  // MARK: Internal

  @MainActor
  override func setUp() {
    getCredentialListUseCase = GetCredentialListUseCaseProtocolSpy()
    checkAndUpdateCredentialStatusUseCase = CheckAndUpdateCredentialStatusUseCaseProtocolSpy()
    isEIDRequestAfterOnboardingEnabledUseCase = IsEIDRequestAfterOnboardingEnabledUseCaseProtocolSpy()
    isEIDRequestAfterOnboardingEnabledUseCase.executeReturnValue = true
    enableEIDRequestAfterOnboardingUseCase = EnableEIDRequestAfterOnboardingUseCaseProtocolSpy()
    getEIDRequestCaseListUseCase = GetEIDRequestCaseListUseCaseProtocolSpy()
    updateEIDRequestCaseStatusUseCase = UpdateEIDRequestCaseStatusUseCaseProtocolSpy()
    deleteEIDRequestCaseUseCase = DeleteEIDRequestCaseUseCaseProtocolSpy()

    Container.shared.getEIDRequestCaseListUseCase.register { self.getEIDRequestCaseListUseCase }
    Container.shared.updateEIDRequestCaseStatusUseCase.register { self.updateEIDRequestCaseStatusUseCase }
    Container.shared.deleteEIDRequestCaseUseCase.register { self.deleteEIDRequestCaseUseCase }

    isUserLoggedInUseCase = IsUserLoggedInUseCaseProtocolSpy()
    isUserLoggedInUseCase.executeReturnValue = true

    Container.shared.isUserLoggedInUseCase.register { self.isUserLoggedInUseCase }
    Container.shared.getCredentialListUseCase.register { self.getCredentialListUseCase }
    Container.shared.checkAndUpdateCredentialStatusUseCase.register { self.checkAndUpdateCredentialStatusUseCase }
    Container.shared.isEIDRequestAfterOnboardingEnabledUseCase.register { self.isEIDRequestAfterOnboardingEnabledUseCase }
    Container.shared.enableEIDRequestAfterOnboardingUseCase.register { self.enableEIDRequestAfterOnboardingUseCase }
    Container.shared.isEIDRequestFeatureEnabled.register { true }

    mockRouter = HomeRouterMock()
    viewModel = HomeViewModel(router: mockRouter)
  }

  @MainActor
  func testInitialValues() {
    XCTAssertFalse(viewModel.isImpressumPresented)
    XCTAssertFalse(viewModel.isSecurityPresented)
    XCTAssertFalse(viewModel.isLicensesPresented)
    XCTAssertFalse(viewModel.isVerificationInstructionPresented)
    XCTAssertEqual(viewModel.state, .results)
    XCTAssertTrue(viewModel.requestCases.isEmpty)
  }

  @MainActor
  func testLoadCredential_happyPath() async {
    getCredentialListUseCase.executeReturnValue = Credential.Mock.array

    await viewModel.send(event: .fetchCredentials)
    XCTAssertEqual(viewModel.credentials, Credential.Mock.array)

    XCTAssertTrue(getCredentialListUseCase.executeCalled)
    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 1)
    XCTAssertEqual(viewModel.state, .results)
  }

  @MainActor
  func testLoadCredential_emptyPath() async {
    getCredentialListUseCase.executeReturnValue = []
    await viewModel.send(event: .fetchCredentials)
    XCTAssertEqual(viewModel.credentials, [])

    XCTAssertTrue(getCredentialListUseCase.executeCalled)
    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 1)
    XCTAssertEqual(viewModel.state, .empty)
  }

  @MainActor
  func testRefresh() async {
    await testLoadCredential_emptyPath()
    getCredentialListUseCase.executeReturnValue = Credential.Mock.array
    XCTAssertFalse(getCredentialListUseCase.executeReturnValue.isEmpty)
    await viewModel.send(event: .refresh)

    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 2)
    XCTAssertEqual(viewModel.state, .results)
  }

  @MainActor
  func testOnAppear() async {
    await testLoadCredential_emptyPath()

    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 1)
    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.executeCallsCount, 0)
    XCTAssertEqual(viewModel.state, .empty)
    isUserLoggedInUseCase.executeReturnValue = false

    await viewModel.onAppear()

    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 1)
    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.executeCallsCount, 0)
    XCTAssertEqual(viewModel.state, .empty)
  }

  @MainActor
  func testRefreshWithoutCredential() async {
    await testLoadCredential_emptyPath()

    getCredentialListUseCase.executeReturnValue = []
    XCTAssertTrue(getCredentialListUseCase.executeReturnValue.isEmpty)
    await viewModel.send(event: .refresh)

    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 2)
    XCTAssertEqual(viewModel.state, .empty)
  }

  @MainActor
  func testRefreshWithCredentials() async {
    await testLoadCredential_happyPath()

    getCredentialListUseCase.executeReturnValue = Credential.Mock.array
    XCTAssertFalse(getCredentialListUseCase.executeReturnValue.isEmpty)
    await viewModel.send(event: .refresh)

    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 2)
    XCTAssertEqual(viewModel.state, .results)
  }

  @MainActor
  func testRefresh_fetchHappyPath_thenFailurePath() async {
    await testLoadCredential_happyPath()
    getCredentialListUseCase.executeThrowableError = TestingError.error
    await viewModel.send(event: .refresh)

    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 2)
    XCTAssertEqual(viewModel.state, .results)
  }

  @MainActor
  func testRefresh_fetchEmpty_thenFailurePath() async {
    await testLoadCredential_emptyPath()
    getCredentialListUseCase.executeThrowableError = TestingError.error
    await viewModel.send(event: .refresh)

    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 2)
    XCTAssertEqual(viewModel.state, .error)
  }

  @MainActor
  func testLoadCredential_failurePath() async {
    getCredentialListUseCase.executeThrowableError = TestingError.error
    await viewModel.send(event: .fetchCredentials)
    XCTAssertEqual(viewModel.credentials, [])

    XCTAssertTrue(getCredentialListUseCase.executeCalled)
    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 1)
    XCTAssertEqual(viewModel.state, .error)
  }

  @MainActor
  func testCheckAllCredentialsStatus_Success() async throws {
    isUserLoggedInUseCase.executeReturnValue = true
    getCredentialListUseCase.executeReturnValue = mockCrendentials
    checkAndUpdateCredentialStatusUseCase.executeReturnValue = mockCrendentials

    await viewModel.send(event: .checkCredentialsStatus)

    XCTAssertEqual(viewModel.state, .results)
    XCTAssertTrue(checkAndUpdateCredentialStatusUseCase.executeCalled)
    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.executeReturnValue.count, mockCrendentials.count)
  }

  @MainActor
  func testCheckAllCredentialsStatus_userLoggedOut() async throws {
    getCredentialListUseCase.executeReturnValue = mockCrendentials
    checkAndUpdateCredentialStatusUseCase.executeReturnValue = mockCrendentials

    isUserLoggedInUseCase.executeReturnValue = false

    await viewModel.send(event: .checkCredentialsStatus)

    XCTAssertEqual(viewModel.state, .results)
    XCTAssertTrue(checkAndUpdateCredentialStatusUseCase.executeCalled)
    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.executeCallsCount, 1)
  }

  @MainActor
  func testCheckAllCredentialsStatus_failure() async throws {
    isUserLoggedInUseCase.executeReturnValue = true
    getCredentialListUseCase.executeReturnValue = mockCrendentials
    checkAndUpdateCredentialStatusUseCase.executeThrowableError = TestingError.error

    await viewModel.send(event: .checkCredentialsStatus)

    XCTAssertEqual(viewModel.state, .results)
    XCTAssertNil(viewModel.stateError)
  }

  @MainActor
  func testOpenScanner() {
    viewModel.openScanner()

    XCTAssertTrue(mockRouter.didCallInvitation)
  }

  @MainActor
  func testOpenSettings() {
    viewModel.openSettings()

    XCTAssertTrue(mockRouter.didCallSettings)
  }

  @MainActor
  func testOpenHelp() {
    viewModel.openHelp()

    XCTAssertTrue(mockRouter.didCallExternalLinkUrl)
  }

  @MainActor
  func testOpenContact() {
    viewModel.openContact()

    XCTAssertTrue(mockRouter.didCallExternalLinkUrl)
  }

  @MainActor
  func testOpenFeedback() {
    viewModel.openFeedback()

    XCTAssertTrue(mockRouter.didCallExternalLinkUrl)
  }

  @MainActor
  func testOpenImpressum() {
    viewModel.openImpressum()

    XCTAssertTrue(viewModel.isImpressumPresented)
  }

  @MainActor
  func testOpenLicenses() {
    viewModel.openLicenses()

    XCTAssertTrue(viewModel.isLicensesPresented)
  }

  @MainActor
  func testOpenSecurity() {
    viewModel.openSecurity()

    XCTAssertTrue(viewModel.isSecurityPresented)
  }

  @MainActor
  func testOpenCredentialDetai() {
    viewModel.openDetail(for: .Mock.sample)

    XCTAssertTrue(mockRouter.didCallOpenCredentialDetail)
  }

  @MainActor
  func testOpenBetaId() {
    viewModel.openBetaId()

    XCTAssertTrue(mockRouter.didCallBetaId)
  }

  @MainActor
  func testOpenEIDRequest() {
    viewModel.openEIDRequest()

    XCTAssertTrue(mockRouter.didCallEIDRequest)
  }

  @MainActor
  func testOnAppear_isEIDRequestFeatureEnabled() async {
    getCredentialListUseCase.executeReturnValue = Credential.Mock.array

    viewModel = HomeViewModel(router: mockRouter)

    await viewModel.onAppear()

    XCTAssertTrue(isEIDRequestAfterOnboardingEnabledUseCase.executeCalled)
    XCTAssertTrue(mockRouter.didCallEIDRequest)
    XCTAssertEqual(enableEIDRequestAfterOnboardingUseCase.executeReceivedEnable, false)
  }

  @MainActor
  func testOnAppear_isEIDRequestFeatureDisabled() async {
    getCredentialListUseCase.executeReturnValue = Credential.Mock.array
    Container.shared.isEIDRequestFeatureEnabled.register { false }

    viewModel = HomeViewModel(router: mockRouter)

    await viewModel.onAppear()

    XCTAssertFalse(mockRouter.didCallEIDRequest)
  }

  @MainActor
  func testOnAppear_FirstLaunch() async {
    getCredentialListUseCase.executeReturnValue = []

    await viewModel.onAppear()

    XCTAssertTrue(getCredentialListUseCase.executeCalled)
    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 1)
    XCTAssertFalse(checkAndUpdateCredentialStatusUseCase.executeCalled)

    XCTAssertTrue(isEIDRequestAfterOnboardingEnabledUseCase.executeCalled)
    XCTAssertTrue(mockRouter.didCallEIDRequest)
    XCTAssertEqual(enableEIDRequestAfterOnboardingUseCase.executeReceivedEnable, false)
  }

  @MainActor
  func testOnAppear_NotFirstLaunch() async {
    getCredentialListUseCase.executeReturnValue = Credential.Mock.array
    isEIDRequestAfterOnboardingEnabledUseCase.executeReturnValue = false
    Container.shared.isEIDRequestAfterOnboardingEnabledUseCase.register { self.isEIDRequestAfterOnboardingEnabledUseCase }

    viewModel = HomeViewModel(router: mockRouter)

    await viewModel.onAppear()

    XCTAssertTrue(isEIDRequestAfterOnboardingEnabledUseCase.executeCalled)
    XCTAssertFalse(mockRouter.didCallEIDRequest)
  }

  @MainActor
  func testGetCredentialsList_happyPath() async {
    getCredentialListUseCase.executeReturnValue = Credential.Mock.array

    await viewModel.send(event: .fetchCredentials)

    XCTAssertTrue(getCredentialListUseCase.executeCalled)
    XCTAssertEqual(viewModel.state, .results)
  }

  @MainActor
  func testGetRequestCasesList_success() async throws {
    getEIDRequestCaseListUseCase.executeReturnValue = mockEIDRequestCases
    updateEIDRequestCaseStatusUseCase.executeReturnValue = mockEIDRequestCases

    await viewModel.getEIDRequestCases()

    XCTAssertEqual(viewModel.requestCases.count, mockEIDRequestCases.count)
    XCTAssertTrue(getEIDRequestCaseListUseCase.executeCalled)
    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeReceivedRequestCaseIds, mockEIDRequestCases.map(\.id))
  }

  @MainActor
  func testGetRequestCasesList_failure() async {
    getEIDRequestCaseListUseCase.executeThrowableError = TestingError.error

    await viewModel.getEIDRequestCases()

    XCTAssertTrue(viewModel.requestCases.isEmpty)
    XCTAssertTrue(getEIDRequestCaseListUseCase.executeCalled)
    XCTAssertFalse(updateEIDRequestCaseStatusUseCase.executeCalled)
  }

  @MainActor
  func testUpdateRequestCasesStatus_success() async throws {
    updateEIDRequestCaseStatusUseCase.executeReturnValue = mockEIDRequestCases

    await viewModel.fetchEIDRequestStatus()

    XCTAssertEqual(viewModel.requestCases.count, mockEIDRequestCases.count)
  }

  @MainActor
  func testUpdateRequestCasesStatus_failure() async throws {
    let mockRequestCases = try mockEIDRequestCases.map { try RequestCaseViewState($0, delegate: viewModel) }
    updateEIDRequestCaseStatusUseCase.executeThrowableError = TestingError.error

    viewModel.requestCases = mockRequestCases

    await viewModel.fetchEIDRequestStatus()

    XCTAssertEqual(mockRequestCases, viewModel.requestCases)
  }

  @MainActor
  func testDidStartAutoVerification() {
    viewModel.didStartAutoVerification()

    XCTAssertTrue(mockRouter.didCallAutoVerification)
  }

  // MARK: Private

  // swiftlint:disable all
  private let mockCrendentials = Credential.Mock.array
  private var getCredentialListUseCase: GetCredentialListUseCaseProtocolSpy!
  private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocolSpy!
  private var isEIDRequestAfterOnboardingEnabledUseCase: IsEIDRequestAfterOnboardingEnabledUseCaseProtocolSpy!
  private var enableEIDRequestAfterOnboardingUseCase: EnableEIDRequestAfterOnboardingUseCaseProtocolSpy!
  private var deleteEIDRequestCaseUseCase: DeleteEIDRequestCaseUseCaseProtocolSpy!
  private var viewModel: HomeViewModel!
  private var mockRouter: HomeRouterMock!
  private var getEIDRequestCaseListUseCase: GetEIDRequestCaseListUseCaseProtocolSpy!
  private var updateEIDRequestCaseStatusUseCase: UpdateEIDRequestCaseStatusUseCaseProtocolSpy!
  private var mockEIDRequestCases: [EIDRequestCase] = [.Mock.sampleInQueue, .Mock.sampleInQueue, .Mock.sampleAVReady]
  private var isUserLoggedInUseCase: IsUserLoggedInUseCaseProtocolSpy!
  // swiftlint:enable all

}
