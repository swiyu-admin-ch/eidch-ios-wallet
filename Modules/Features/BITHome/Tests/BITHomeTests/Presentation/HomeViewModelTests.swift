import Factory
import XCTest
@testable import BITAppAuth
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITEIDRequest
@testable import BITHome
@testable import BITTestingCore

@MainActor
final class HomeViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    getCredentialListUseCase = GetCredentialListUseCaseProtocolSpy()
    checkAndUpdateCredentialStatusUseCase = CheckAndUpdateCredentialStatusUseCaseProtocolSpy()
    isEIDRequestAfterOnboardingEnabledUseCase = IsEIDRequestAfterOnboardingEnabledUseCaseProtocolSpy()
    isEIDRequestAfterOnboardingEnabledUseCase.executeReturnValue = true
    enableEIDRequestAfterOnboardingUseCase = EnableEIDRequestAfterOnboardingUseCaseProtocolSpy()
    getEIDRequestCaseListUseCase = GetEIDRequestCaseListUseCaseProtocolSpy()
    updateEIDRequestCaseStatusUseCase = UpdateEIDRequestCaseStatusUseCaseProtocolSpy()
    deleteEIDRequestCaseUseCase = DeleteEIDRequestCaseUseCaseProtocolSpy()
    getCredentialDisplayUseCase = GetCredentialDisplayUseCaseProtocolSpy()

    Container.shared.getEIDRequestCaseListUseCase.register { self.getEIDRequestCaseListUseCase }
    Container.shared.updateEIDRequestCaseStatusUseCase.register { self.updateEIDRequestCaseStatusUseCase }
    Container.shared.deleteEIDRequestCaseUseCase.register { self.deleteEIDRequestCaseUseCase }
    Container.shared.getCredentialDisplayUseCase.register { self.getCredentialDisplayUseCase }

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

  func testInitialValues() {
    XCTAssertFalse(viewModel.isImpressumPresented)
    XCTAssertFalse(viewModel.isSecurityPresented)
    XCTAssertFalse(viewModel.isLicensesPresented)
    XCTAssertFalse(viewModel.isVerificationInstructionPresented)
    XCTAssertEqual(viewModel.state, .results)
    XCTAssertTrue(viewModel.requestCases.isEmpty)
  }

  func testLoadCredential_happyPath() async {
    getCredentialListUseCase.executeReturnValue = Credential.Mock.array

    await viewModel.send(event: .fetchCredentials)
    XCTAssertEqual(viewModel.credentialViewModels.map(\.credential), Credential.Mock.array)

    XCTAssertTrue(getCredentialListUseCase.executeCalled)
    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 1)
    XCTAssertEqual(viewModel.state, .results)
  }

  func testLoadCredential_emptyPath() async {
    getCredentialListUseCase.executeReturnValue = []
    await viewModel.send(event: .fetchCredentials)
    XCTAssertTrue(viewModel.credentialViewModels.isEmpty)

    XCTAssertTrue(getCredentialListUseCase.executeCalled)
    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 1)
    XCTAssertEqual(viewModel.state, .empty)
  }

  func testRefresh() async {
    await testLoadCredential_emptyPath()
    getCredentialListUseCase.executeReturnValue = Credential.Mock.array
    XCTAssertFalse(getCredentialListUseCase.executeReturnValue.isEmpty)
    await viewModel.send(event: .refresh)

    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 2)
    XCTAssertEqual(viewModel.state, .results)
  }

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

  func testRefreshWithoutCredential() async {
    await testLoadCredential_emptyPath()

    getCredentialListUseCase.executeReturnValue = []
    XCTAssertTrue(getCredentialListUseCase.executeReturnValue.isEmpty)
    await viewModel.send(event: .refresh)

    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 2)
    XCTAssertEqual(viewModel.state, .empty)
  }

  func testRefreshWithCredentials() async {
    await testLoadCredential_happyPath()

    getCredentialListUseCase.executeReturnValue = Credential.Mock.array
    XCTAssertFalse(getCredentialListUseCase.executeReturnValue.isEmpty)
    await viewModel.send(event: .refresh)

    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 2)
    XCTAssertEqual(viewModel.state, .results)
  }

  func testRefresh_fetchHappyPath_thenFailurePath() async {
    await testLoadCredential_happyPath()
    getCredentialListUseCase.executeThrowableError = TestingError.error
    await viewModel.send(event: .refresh)

    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 2)
    XCTAssertEqual(viewModel.state, .results)
  }

  func testRefresh_fetchEmpty_thenFailurePath() async {
    await testLoadCredential_emptyPath()
    getCredentialListUseCase.executeThrowableError = TestingError.error
    await viewModel.send(event: .refresh)

    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 2)
    XCTAssertEqual(viewModel.state, .error)
  }

  func testLoadCredential_failurePath() async {
    getCredentialListUseCase.executeThrowableError = TestingError.error
    await viewModel.send(event: .fetchCredentials)
    XCTAssertTrue(viewModel.credentialViewModels.isEmpty)

    XCTAssertTrue(getCredentialListUseCase.executeCalled)
    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 1)
    XCTAssertEqual(viewModel.state, .error)
  }

  func testCheckAllCredentialsStatus_Success() async throws {
    isUserLoggedInUseCase.executeReturnValue = true
    getCredentialListUseCase.executeReturnValue = mockCrendentials
    checkAndUpdateCredentialStatusUseCase.executeReturnValue = mockCrendentials

    await viewModel.send(event: .checkCredentialsStatus)

    XCTAssertEqual(viewModel.state, .results)
    XCTAssertTrue(checkAndUpdateCredentialStatusUseCase.executeCalled)
    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.executeReturnValue.count, mockCrendentials.count)
  }

  func testCheckAllCredentialsStatus_userLoggedOut() async throws {
    getCredentialListUseCase.executeReturnValue = mockCrendentials
    checkAndUpdateCredentialStatusUseCase.executeReturnValue = mockCrendentials

    isUserLoggedInUseCase.executeReturnValue = false

    await viewModel.send(event: .checkCredentialsStatus)

    XCTAssertEqual(viewModel.state, .results)
    XCTAssertTrue(checkAndUpdateCredentialStatusUseCase.executeCalled)
    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.executeCallsCount, 1)
  }

  func testCheckAllCredentialsStatus_failure() async throws {
    isUserLoggedInUseCase.executeReturnValue = true
    getCredentialListUseCase.executeReturnValue = mockCrendentials
    checkAndUpdateCredentialStatusUseCase.executeThrowableError = TestingError.error

    await viewModel.send(event: .checkCredentialsStatus)

    XCTAssertEqual(viewModel.state, .results)
    XCTAssertNil(viewModel.stateError)
  }

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

  func testOpenContact() {
    viewModel.openContact()

    XCTAssertTrue(mockRouter.didCallExternalLinkUrl)
  }

  func testOpenFeedback() {
    viewModel.openFeedback()

    XCTAssertTrue(mockRouter.didCallExternalLinkUrl)
  }

  func testOpenImpressum() {
    viewModel.openImpressum()

    XCTAssertTrue(viewModel.isImpressumPresented)
  }

  func testOpenLicenses() {
    viewModel.openLicenses()

    XCTAssertTrue(viewModel.isLicensesPresented)
  }

  func testOpenSecurity() {
    viewModel.openSecurity()

    XCTAssertTrue(viewModel.isSecurityPresented)
  }

  func testOpenCredentialDetai() {
    viewModel.openDetail(for: .Mock.sample)

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

  func testOnAppear_isEIDRequestFeatureEnabled() async {
    getCredentialListUseCase.executeReturnValue = Credential.Mock.array

    viewModel = HomeViewModel(router: mockRouter)

    await viewModel.onAppear()

    XCTAssertTrue(isEIDRequestAfterOnboardingEnabledUseCase.executeCalled)
    XCTAssertTrue(mockRouter.didCallEIDRequest)
    XCTAssertEqual(enableEIDRequestAfterOnboardingUseCase.executeReceivedEnable, false)
  }

  func testOnAppear_isEIDRequestFeatureDisabled() async {
    getCredentialListUseCase.executeReturnValue = Credential.Mock.array
    Container.shared.isEIDRequestFeatureEnabled.register { false }

    viewModel = HomeViewModel(router: mockRouter)

    await viewModel.onAppear()

    XCTAssertFalse(mockRouter.didCallEIDRequest)
  }

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

  func testOnAppear_NotFirstLaunch() async {
    getCredentialListUseCase.executeReturnValue = Credential.Mock.array
    isEIDRequestAfterOnboardingEnabledUseCase.executeReturnValue = false
    Container.shared.isEIDRequestAfterOnboardingEnabledUseCase.register { self.isEIDRequestAfterOnboardingEnabledUseCase }

    viewModel = HomeViewModel(router: mockRouter)

    await viewModel.onAppear()

    XCTAssertTrue(isEIDRequestAfterOnboardingEnabledUseCase.executeCalled)
    XCTAssertFalse(mockRouter.didCallEIDRequest)
  }

  func testGetCredentialsList_happyPath() async {
    getCredentialListUseCase.executeReturnValue = Credential.Mock.array

    await viewModel.send(event: .fetchCredentials)

    XCTAssertTrue(getCredentialListUseCase.executeCalled)
    XCTAssertEqual(viewModel.state, .results)
  }

  func testGetRequestCasesList_success() async throws {
    getEIDRequestCaseListUseCase.executeReturnValue = mockEIDRequestCases
    updateEIDRequestCaseStatusUseCase.executeReturnValue = mockEIDRequestCases

    await viewModel.getEIDRequestCases()

    XCTAssertEqual(viewModel.requestCases.count, mockEIDRequestCases.count)
    XCTAssertTrue(getEIDRequestCaseListUseCase.executeCalled)
    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeReceivedRequestCaseIds, mockEIDRequestCases.map(\.id))
  }

  func testGetRequestCasesList_failure() async {
    getEIDRequestCaseListUseCase.executeThrowableError = TestingError.error

    await viewModel.getEIDRequestCases()

    XCTAssertTrue(viewModel.requestCases.isEmpty)
    XCTAssertTrue(getEIDRequestCaseListUseCase.executeCalled)
    XCTAssertFalse(updateEIDRequestCaseStatusUseCase.executeCalled)
  }

  func testUpdateRequestCasesStatus_success() async throws {
    updateEIDRequestCaseStatusUseCase.executeReturnValue = mockEIDRequestCases

    await viewModel.fetchEIDRequestStatus()

    XCTAssertEqual(viewModel.requestCases.count, mockEIDRequestCases.count)
  }

  func testUpdateRequestCasesStatus_failure() async throws {
    let mockRequestCases = try mockEIDRequestCases.map { try RequestCaseViewState($0, delegate: viewModel) }
    updateEIDRequestCaseStatusUseCase.executeThrowableError = TestingError.error

    viewModel.requestCases = mockRequestCases

    await viewModel.fetchEIDRequestStatus()

    XCTAssertEqual(mockRequestCases, viewModel.requestCases)
  }

  func testDidStartAutoVerification() {
    viewModel.didStartAutoVerification(caseId: mockCaseId)

    XCTAssertEqual(mockRouter.didCallAutoVerificationArgument, mockCaseId)
  }

  func testDidTapObtainConsent() {
    viewModel.didTapObtainConsent(caseId: mockCaseId)

    XCTAssertEqual(mockRouter.didCallObtainConsentArgument, mockCaseId)
  }

  func testUpdateCredentialViewModels_light_setsViewModel() async {
    let credentialMocks: [Credential] = [.Mock.diploma, .Mock.sample]
    getCredentialListUseCase.executeReturnValue = credentialMocks
    var calls = 0
    getCredentialDisplayUseCase.executeForColorSchemeClosure = { _, _ in
      if calls <= 2 {
        calls += 1
        return .Mock.lightEnglish
      }
      return .Mock.sample
    }
    await viewModel.send(event: .fetchCredentials) // set up credentials which will already trigger an updateCredentialViewModels

    viewModel.updateCredentialViewModels(with: themeMock)

    XCTAssertEqual(viewModel.credentialViewModels[0].credentialDisplay, .Mock.lightEnglish)
    XCTAssertEqual(viewModel.credentialViewModels[0].credential, credentialMocks[0])
    XCTAssertEqual(viewModel.credentialViewModels[1].credentialDisplay, .Mock.sample)
    XCTAssertEqual(viewModel.credentialViewModels[1].credential, credentialMocks[1])
  }

  func testUpdateCredentialViewModels_argumentsPassed() async {
    let credentialMocks: [Credential] = [.Mock.diploma, .Mock.sample]
    getCredentialListUseCase.executeReturnValue = credentialMocks
    await viewModel.send(event: .fetchCredentials) // set up credentials which will already trigger an updateCredentialViewModels

    viewModel.updateCredentialViewModels(with: themeMock)

    XCTAssertEqual(getCredentialDisplayUseCase.executeForColorSchemeReceivedInvocations[2].colorScheme, themeMock)
    XCTAssertEqual(getCredentialDisplayUseCase.executeForColorSchemeReceivedInvocations[2].displays, credentialMocks[0].displays)
    XCTAssertEqual(getCredentialDisplayUseCase.executeForColorSchemeReceivedInvocations[3].colorScheme, themeMock)
    XCTAssertEqual(getCredentialDisplayUseCase.executeForColorSchemeReceivedInvocations[3].displays, credentialMocks[1].displays)
  }

  // MARK: Private

  // swiftlint:disable all
  private let mockCaseId = "caseId"
  private let mockCrendentials = Credential.Mock.array
  private let themeMock = "light"
  private var getCredentialListUseCase: GetCredentialListUseCaseProtocolSpy!
  private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocolSpy!
  private var isEIDRequestAfterOnboardingEnabledUseCase: IsEIDRequestAfterOnboardingEnabledUseCaseProtocolSpy!
  private var enableEIDRequestAfterOnboardingUseCase: EnableEIDRequestAfterOnboardingUseCaseProtocolSpy!
  private var deleteEIDRequestCaseUseCase: DeleteEIDRequestCaseUseCaseProtocolSpy!
  private var viewModel: HomeViewModel!
  private var mockRouter: HomeRouterMock!
  private var getEIDRequestCaseListUseCase: GetEIDRequestCaseListUseCaseProtocolSpy!
  private var updateEIDRequestCaseStatusUseCase: UpdateEIDRequestCaseStatusUseCaseProtocolSpy!
  private var getCredentialDisplayUseCase: GetCredentialDisplayUseCaseProtocolSpy!
  private var mockEIDRequestCases: [EIDRequestCase] = [.Mock.sampleInQueue, .Mock.sampleInQueue, .Mock.sampleAVReady]
  private var isUserLoggedInUseCase: IsUserLoggedInUseCaseProtocolSpy!
  // swiftlint:enable all

}
