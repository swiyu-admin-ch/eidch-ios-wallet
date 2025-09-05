// swiftlint:disable force_unwrapping implicitly_unwrapped_optional
import Factory
import XCTest
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITOpenID
@testable import BITPresentation
@testable import BITTestingCore

@MainActor
class PresentationRequestReviewViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    context = .Mock.vcSdJwtSample
    credentialMock = context.selectedCredentials[context.selectedCredentials.first!.key]!.credential

    Container.shared.reset()
    Container.shared.submitPresentationUseCase.register { self.submitPresentationUseCase }
    Container.shared.declinePresentationUseCase.register { self.declinePresentationUseCase }
    Container.shared.getVerifierDisplayUseCase.register { self.getVerifierDisplayUseCase }
    Container.shared.getCredentialDisplayUseCase.register { self.getCredentialDisplayUseCase }

    router = MockPresentationRouter()

    viewModel = PresentationRequestReviewViewModel(context: context, router: router)
  }

  func testInitialStateWithoutVerifierDisplay_withoutTrustStatement() {
    getVerifierDisplayUseCase.executeForTrustStatementReturnValue = mockUnTrustedVerifierDisplay
    viewModel = PresentationRequestReviewViewModel(context: context, router: router)

    XCTAssertFalse(viewModel.showLoadingMessage)
    XCTAssertEqual(viewModel.verifierDisplay, mockUnTrustedVerifierDisplay)
    XCTAssertEqual(getVerifierDisplayUseCase.executeForTrustStatementReceivedArguments?.trustStatement, context.trustStatement)
    XCTAssertEqual(getVerifierDisplayUseCase.executeForTrustStatementReceivedArguments?.verifier, context.requestObject.clientMetadata)
  }

  func testInitialStateWithoutVerifierDisplay_withTrustStatement() {
    getVerifierDisplayUseCase.executeForTrustStatementReturnValue = mockTrustedVerifierDisplay
    viewModel = PresentationRequestReviewViewModel(context: context, router: router)

    XCTAssertFalse(viewModel.showLoadingMessage)
    XCTAssertEqual(viewModel.verifierDisplay, mockTrustedVerifierDisplay)
    XCTAssertEqual(getVerifierDisplayUseCase.executeForTrustStatementReceivedArguments?.trustStatement, context.trustStatement)
    XCTAssertEqual(getVerifierDisplayUseCase.executeForTrustStatementReceivedArguments?.verifier, context.requestObject.clientMetadata)
  }

  func testSubmitPresentation_Success_NavigateToSuccess() async throws {
    await viewModel.submit()

    XCTAssertEqual(viewModel.state, .loading)
    XCTAssertFalse(viewModel.showLoadingMessage)
    XCTAssertTrue(submitPresentationUseCase.executeContextCalled)
    XCTAssertEqual(router.calledPresentationResultState, .success(claims: viewModel.credential.requestedClusteredClaims.flatMap(\.claims)))
    XCTAssertFalse(declinePresentationUseCase.executeRequestObjectCalled)
  }

  func testSubmitPresentation_ErrorThrown_ErrorState() async throws {
    submitPresentationUseCase.executeContextThrowableError = TestingError.error

    await viewModel.submit()

    XCTAssertEqual(viewModel.state, .result)
    XCTAssertFalse(viewModel.showLoadingMessage)
    XCTAssertEqual(router.calledPresentationResultState, .error)
    XCTAssertTrue(submitPresentationUseCase.executeContextCalled)
    XCTAssertFalse(declinePresentationUseCase.executeRequestObjectCalled)
  }

  func testSubmitPresentation_CredentialInvalid_ErrorState() async throws {
    submitPresentationUseCase.executeContextThrowableError = BITPresentation.SubmitPresentationError.invalidCredential

    await viewModel.submit()

    XCTAssertEqual(viewModel.state, .result)
    XCTAssertFalse(viewModel.showLoadingMessage)
    XCTAssertEqual(router.calledPresentationResultState, .invalidCredential(claims: viewModel.credential.requestedClusteredClaims.flatMap(\.claims)))
    XCTAssertTrue(submitPresentationUseCase.executeContextCalled)
    XCTAssertFalse(declinePresentationUseCase.executeRequestObjectCalled)
  }

  func testSubmitPresentation_ProcessClosed_PresentationCancelledState() async throws {
    submitPresentationUseCase.executeContextThrowableError = BITPresentation.SubmitPresentationError.processClosed

    await viewModel.submit()

    XCTAssertEqual(viewModel.state, .result)
    XCTAssertFalse(viewModel.showLoadingMessage)
    XCTAssertEqual(router.calledPresentationResultState, .cancelled)
    XCTAssertTrue(submitPresentationUseCase.executeContextCalled)
    XCTAssertFalse(declinePresentationUseCase.executeRequestObjectCalled)
  }

  func testDeny() async throws {
    await viewModel.deny()
    try await viewModel.denyTask?.value

    XCTAssertFalse(viewModel.showLoadingMessage)
    XCTAssertEqual(router.calledPresentationResultState, .deny)
    XCTAssertTrue(declinePresentationUseCase.executeRequestObjectCalled)
    XCTAssertEqual(declinePresentationUseCase.executeRequestObjectReceivedRequestObject, context.requestObject)
    XCTAssertFalse(submitPresentationUseCase.executeContextCalled)
  }

  func testDeny_withError() async throws {
    declinePresentationUseCase.executeRequestObjectThrowableError = TestingError.error

    await viewModel.deny()
    try await viewModel.denyTask?.value

    XCTAssertFalse(viewModel.showLoadingMessage)
    XCTAssertEqual(router.calledPresentationResultState, .deny)
    XCTAssertTrue(declinePresentationUseCase.executeRequestObjectCalled)
    XCTAssertEqual(declinePresentationUseCase.executeRequestObjectReceivedRequestObject, context.requestObject)
    XCTAssertFalse(submitPresentationUseCase.executeContextCalled)
  }

  func testUpdateCredentialViewModel_light_setsViewModel() {
    getCredentialDisplayUseCase.executeForColorSchemeReturnValue = .Mock.lightEnglish

    viewModel.updateCredentialViewModel(with: themeMock)

    XCTAssertEqual(viewModel.credentialViewModel?.credentialDisplay, .Mock.lightEnglish)
    XCTAssertEqual(viewModel.credentialViewModel?.credential, credentialMock)
  }

  func testUpdateCredentialViewModel_argumentsPassed() {
    getCredentialDisplayUseCase.executeForColorSchemeReturnValue = .Mock.lightEnglish

    viewModel.updateCredentialViewModel(with: themeMock)

    XCTAssertEqual(getCredentialDisplayUseCase.executeForColorSchemeReceivedArguments?.colorScheme, themeMock)
    XCTAssertEqual(getCredentialDisplayUseCase.executeForColorSchemeReceivedArguments?.displays, credentialMock.displays)
  }

  // MARK: Private

  private var viewModel: PresentationRequestReviewViewModel!
  private var context: PresentationRequestContext!
  private var credentialMock: Credential!
  private var submitPresentationUseCase = SubmitPresentationUseCaseProtocolSpy()
  private var declinePresentationUseCase = DeclinePresentationUseCaseProtocolSpy()
  private var getVerifierDisplayUseCase = GetVerifierDisplayUseCaseProtocolSpy()
  private var getCredentialDisplayUseCase = GetCredentialDisplayUseCaseProtocolSpy()
  private var router = MockPresentationRouter()
  private var mockTrustedVerifierDisplay = VerifierDisplay(name: "name", logo: Data(), trustStatus: .verified)
  private var mockUnTrustedVerifierDisplay = VerifierDisplay(name: "name", logo: Data(), trustStatus: .unverified)
  private let themeMock = "light"
}

// swiftlint:enable all
