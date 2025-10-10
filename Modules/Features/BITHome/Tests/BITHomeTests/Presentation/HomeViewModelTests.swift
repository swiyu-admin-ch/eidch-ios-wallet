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
    XCTAssertTrue(viewModel.requestCases.isEmpty)
    XCTAssertTrue(viewModel.credentialViewModels.isEmpty)
  }

  // MARK: - onAppear()

  func testOnAppear_eIDRequestFeatureEnabled_success() async {
    await viewModel.onAppear()

    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 1)
    XCTAssertEqual(getEIDRequestCaseListUseCase.executeCallsCount, 1)
    XCTAssertEqual(enableEIDRequestAfterOnboardingUseCase.executeReceivedEnable, false)
  }

  func testOnAppear_eIDRequestFeatureNotEnabled_routeToEidRequest() async {
    Container.shared.isEIDRequestFeatureEnabled.register { false }

    await viewModel.onAppear()

    XCTAssertTrue(mockRouter.didCallEIDRequest)
    XCTAssertTrue(enableEIDRequestAfterOnboardingUseCase.executeCalled)

    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 1)
    XCTAssertEqual(getEIDRequestCaseListUseCase.executeCallsCount, 1)
  }

  // MARK: - fetchCredential()

  func testFetchCredentials_withCredentials_success() async {
    await viewModel.fetchCredentials()

    XCTAssertEqual(viewModel.state, .results)
    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 1)
    XCTAssertEqual(viewModel.credentialViewModels.map(\.credential), mockCrendentials)
  }

  func testFetchCredentials_withoutCredentials_success() async {
    getCredentialListUseCase.executeReturnValue = []

    await viewModel.fetchCredentials()

    XCTAssertEqual(viewModel.state, .empty)
    XCTAssertTrue(viewModel.credentialViewModels.isEmpty)
    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 1)
  }

  func testFetchCredentials_getCredentialsThrows_failure() async {
    getCredentialListUseCase.executeThrowableError = TestingError.error

    await viewModel.fetchCredentials()

    XCTAssertEqual(viewModel.state, .error(TestingError.error))
    XCTAssertTrue(viewModel.credentialViewModels.isEmpty)
    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 1)
  }

  // MARK: - fetchCredentialStatus()

  func testFetchCredentialStatus_success() async {
    await viewModel.fetchCredentialStatus()

    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.executeCallsCount, 1)
    XCTAssertEqual(checkAndUpdateCredentialStatusUseCase.executeReturnValue.count, mockCrendentials.count)
    XCTAssertEqual(getCredentialListUseCase.executeCallsCount, 1)
  }

  func testFetchCredentialStatus_checkStatusThrows_failure() async {
    checkAndUpdateCredentialStatusUseCase.executeThrowableError = TestingError.error

    await viewModel.fetchCredentialStatus()

    XCTAssertFalse(getCredentialListUseCase.executeCalled)
  }


  func testGetRequestCasesList_withCases_success() async throws {
    await viewModel.getEIDRequestCases()

    XCTAssertEqual(viewModel.requestCases.count, mockEIDRequestCases.count)
    XCTAssertEqual(getEIDRequestCaseListUseCase.executeCallsCount, 1)
    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeReceivedRequestCaseIds, mockEIDRequestCases.map(\.id))
  }

  func testGetRequestCasesList_withoutCases_success() async throws {
    getEIDRequestCaseListUseCase.executeReturnValue = []

    await viewModel.getEIDRequestCases()

    XCTAssertTrue(viewModel.requestCases.isEmpty)
    XCTAssertFalse(updateEIDRequestCaseStatusUseCase.executeCalled)
  }

  func testGetRequestCasesList_getRequestCasesThrows_failure() async {
    getEIDRequestCaseListUseCase.executeThrowableError = TestingError.error

    await viewModel.getEIDRequestCases()

    XCTAssertTrue(viewModel.requestCases.isEmpty)
    XCTAssertFalse(updateEIDRequestCaseStatusUseCase.executeCalled)
  }

  // MARK: - fetchRequestCaseStatus()

  func testFetchRequestCasesStatus_success() async throws {
    await viewModel.fetchRequestCaseStatus()

    XCTAssertEqual(viewModel.requestCases.count, mockEIDRequestCases.count)
  }

  func testFetchRequestCasesStatus_failure() async throws {
    let mockRequestCases = try mockEIDRequestCases.map { try RequestCaseViewState($0, delegate: viewModel) }
    updateEIDRequestCaseStatusUseCase.executeThrowableError = TestingError.error

    viewModel.requestCases = mockRequestCases

    await viewModel.fetchRequestCaseStatus()

    XCTAssertEqual(mockRequestCases, viewModel.requestCases)
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

  func testOpenCredentialDetail() {
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

  func testDidStartAutoVerification() {
    viewModel.didStartAutoVerification(caseId: mockCaseId)

    XCTAssertEqual(mockRouter.didCallAutoVerificationArgument, mockCaseId)
  }

  func testDidTapObtainConsent() {
    viewModel.didTapObtainConsent(caseId: mockCaseId)

    XCTAssertEqual(mockRouter.didCallObtainConsentArgument, mockCaseId)
  }

  func testDidOpenExternalLink() {
    viewModel.didOpenExternalLink(url: URL(string: "mock_url")!)

    XCTAssertEqual(mockRouter.didCallExternalLinkUrl, true)
  }

  func testUpdateCredentialViewModels_light_setsViewModel() async {
    let credentialMocks: [VerifiableCredential] = [.Mock.diploma, .Mock.sample]
    getCredentialListUseCase.executeReturnValue = credentialMocks
    var calls = 0
    getCredentialDisplayUseCase.executeForColorSchemeClosure = { _, _ in
      if calls <= 2 {
        calls += 1
        return .Mock.lightEnglish
      }
      return .Mock.sample
    }
    await viewModel.fetchCredentials() // set up credentials which will already trigger an updateCredentialViewModels

    viewModel.updateCredentialViewModels(with: themeMock)

    XCTAssertEqual(viewModel.credentialViewModels[0].credentialDisplay, .Mock.lightEnglish)
    XCTAssertEqual(viewModel.credentialViewModels[0].credential, credentialMocks[0])
    XCTAssertEqual(viewModel.credentialViewModels[1].credentialDisplay, .Mock.sample)
    XCTAssertEqual(viewModel.credentialViewModels[1].credential, credentialMocks[1])
  }

  func testUpdateCredentialViewModels_argumentsPassed() async {
    let credentialMocks: [VerifiableCredential] = [.Mock.diploma, .Mock.sample]
    getCredentialListUseCase.executeReturnValue = credentialMocks

    await viewModel.fetchCredentials() // set up credentials which will already trigger an updateCredentialViewModels

    viewModel.updateCredentialViewModels(with: themeMock)

    XCTAssertEqual(getCredentialDisplayUseCase.executeForColorSchemeReceivedInvocations[2].colorScheme, themeMock)
    XCTAssertEqual(getCredentialDisplayUseCase.executeForColorSchemeReceivedInvocations[2].displays, credentialMocks[0].displays)
    XCTAssertEqual(getCredentialDisplayUseCase.executeForColorSchemeReceivedInvocations[3].colorScheme, themeMock)
    XCTAssertEqual(getCredentialDisplayUseCase.executeForColorSchemeReceivedInvocations[3].displays, credentialMocks[1].displays)
  }

  // MARK: Private

  private let mockCaseId = "caseId"
  private let mockCrendentials = VerifiableCredential.Mock.array
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

  private func registerMocks() {
    getCredentialListUseCase = GetCredentialListUseCaseProtocolSpy()
    checkAndUpdateCredentialStatusUseCase = CheckAndUpdateCredentialStatusUseCaseProtocolSpy()
    isEIDRequestAfterOnboardingEnabledUseCase = IsEIDRequestAfterOnboardingEnabledUseCaseProtocolSpy()
    enableEIDRequestAfterOnboardingUseCase = EnableEIDRequestAfterOnboardingUseCaseProtocolSpy()
    getEIDRequestCaseListUseCase = GetEIDRequestCaseListUseCaseProtocolSpy()
    updateEIDRequestCaseStatusUseCase = UpdateEIDRequestCaseStatusUseCaseProtocolSpy()
    deleteEIDRequestCaseUseCase = DeleteEIDRequestCaseUseCaseProtocolSpy()
    getCredentialDisplayUseCase = GetCredentialDisplayUseCaseProtocolSpy()
    isUserLoggedInUseCase = IsUserLoggedInUseCaseProtocolSpy()

    Container.shared.getEIDRequestCaseListUseCase.register { self.getEIDRequestCaseListUseCase }
    Container.shared.updateEIDRequestCaseStatusUseCase.register { self.updateEIDRequestCaseStatusUseCase }
    Container.shared.deleteEIDRequestCaseUseCase.register { self.deleteEIDRequestCaseUseCase }
    Container.shared.getCredentialDisplayUseCase.register { self.getCredentialDisplayUseCase }
    Container.shared.isUserLoggedInUseCase.register { self.isUserLoggedInUseCase }
    Container.shared.getCredentialListUseCase.register { self.getCredentialListUseCase }
    Container.shared.checkAndUpdateCredentialStatusUseCase.register { self.checkAndUpdateCredentialStatusUseCase }
    Container.shared.isEIDRequestAfterOnboardingEnabledUseCase.register { self.isEIDRequestAfterOnboardingEnabledUseCase }
    Container.shared.enableEIDRequestAfterOnboardingUseCase.register { self.enableEIDRequestAfterOnboardingUseCase }
    Container.shared.isEIDRequestFeatureEnabled.register { true }
  }

  private func createSuccesState() {
    isEIDRequestAfterOnboardingEnabledUseCase.executeReturnValue = true
    isUserLoggedInUseCase.executeReturnValue = true
    getCredentialListUseCase.executeReturnValue = mockCrendentials
    getEIDRequestCaseListUseCase.executeReturnValue = mockEIDRequestCases
    updateEIDRequestCaseStatusUseCase.executeReturnValue = mockEIDRequestCases
    checkAndUpdateCredentialStatusUseCase.executeReturnValue = mockCrendentials
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
