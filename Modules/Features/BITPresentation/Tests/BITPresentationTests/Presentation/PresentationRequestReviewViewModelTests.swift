import Factory
import XCTest
@testable import BITOpenID
@testable import BITPresentation
@testable import BITTestingCore

class PresentationRequestReviewViewModelTests: XCTestCase {

  // MARK: Internal

  @MainActor
  override func setUp() {
    context = .Mock.vcSdJwtSample

    Container.shared.reset()
    Container.shared.submitPresentationUseCase.register { self.submitPresentationUseCase }
    Container.shared.denyPresentationUseCase.register { self.denyPresentationUseCase }
    Container.shared.getVerifierDisplayUseCase.register { self.getVerifierDisplayUseCase }

    router = MockPresentationRouter()

    viewModel = PresentationRequestReviewViewModel(context: context, router: router)
  }

  @MainActor
  func testInitialStateWithoutVerifierDisplay_withoutTrustStatement() {
    getVerifierDisplayUseCase.executeForTrustStatementReturnValue = mockUnTrustedVerifierDisplay
    viewModel = PresentationRequestReviewViewModel(context: context, router: router)

    XCTAssertFalse(viewModel.showLoadingMessage)
    XCTAssertEqual(viewModel.verifierDisplay, mockUnTrustedVerifierDisplay)
    XCTAssertEqual(getVerifierDisplayUseCase.executeForTrustStatementReceivedArguments?.trustStatement, context.trustStatement)
    XCTAssertEqual(getVerifierDisplayUseCase.executeForTrustStatementReceivedArguments?.verifier, context.requestObject.clientMetadata)
  }

  @MainActor
  func testInitialStateWithoutVerifierDisplay_withTrustStatement() {
    getVerifierDisplayUseCase.executeForTrustStatementReturnValue = mockTrustedVerifierDisplay
    viewModel = PresentationRequestReviewViewModel(context: context, router: router)

    XCTAssertFalse(viewModel.showLoadingMessage)
    XCTAssertEqual(viewModel.verifierDisplay, mockTrustedVerifierDisplay)
    XCTAssertEqual(getVerifierDisplayUseCase.executeForTrustStatementReceivedArguments?.trustStatement, context.trustStatement)
    XCTAssertEqual(getVerifierDisplayUseCase.executeForTrustStatementReceivedArguments?.verifier, context.requestObject.clientMetadata)
  }

  @MainActor
  func testSubmitPresentation_Success_NavigateToSuccess() async throws {
    await viewModel.submit()

    XCTAssertEqual(viewModel.state, .loading)
    XCTAssertFalse(viewModel.showLoadingMessage)
    XCTAssertTrue(submitPresentationUseCase.executeContextCalled)
    XCTAssertEqual(router.calledPresentationResultState, .success(claims: viewModel.credential.requestedClaims))
    XCTAssertFalse(denyPresentationUseCase.executeRequestObjectErrorCalled)
  }

  @MainActor
  func testSubmitPresentation_ErrorThrown_ErrorState() async throws {
    submitPresentationUseCase.executeContextThrowableError = TestingError.error

    await viewModel.submit()

    XCTAssertEqual(viewModel.state, .result)
    XCTAssertFalse(viewModel.showLoadingMessage)
    XCTAssertEqual(router.calledPresentationResultState, .error)
    XCTAssertTrue(submitPresentationUseCase.executeContextCalled)
    XCTAssertFalse(denyPresentationUseCase.executeRequestObjectErrorCalled)
  }

  @MainActor
  func testSubmitPresentation_CredentialInvalid_ErrorState() async throws {
    submitPresentationUseCase.executeContextThrowableError = PresentationError.invalidCredential

    await viewModel.submit()

    XCTAssertEqual(viewModel.state, .result)
    XCTAssertFalse(viewModel.showLoadingMessage)
    XCTAssertEqual(router.calledPresentationResultState, .invalidCredential(claims: viewModel.credential.requestedClaims))
    XCTAssertTrue(submitPresentationUseCase.executeContextCalled)
    XCTAssertFalse(denyPresentationUseCase.executeRequestObjectErrorCalled)
  }

  @MainActor
  func testSubmitPresentation_ProcessClosed_PresentationCancelledState() async throws {
    submitPresentationUseCase.executeContextThrowableError = PresentationError.processClosed

    await viewModel.submit()

    XCTAssertEqual(viewModel.state, .result)
    XCTAssertFalse(viewModel.showLoadingMessage)
    XCTAssertEqual(router.calledPresentationResultState, .cancelled)
    XCTAssertTrue(submitPresentationUseCase.executeContextCalled)
    XCTAssertFalse(denyPresentationUseCase.executeRequestObjectErrorCalled)
  }

  @MainActor
  func testDeny() async throws {
    await viewModel.deny()
    try await viewModel.denyTask?.value

    XCTAssertFalse(viewModel.showLoadingMessage)
    XCTAssertEqual(router.calledPresentationResultState, .deny)
    XCTAssertTrue(denyPresentationUseCase.executeRequestObjectErrorCalled)
    XCTAssertEqual(denyPresentationUseCase.executeRequestObjectErrorReceivedArguments?.error, .clientRejected)
    XCTAssertFalse(submitPresentationUseCase.executeContextCalled)
  }

  @MainActor
  func testDeny_withError() async throws {
    denyPresentationUseCase.executeRequestObjectErrorThrowableError = TestingError.error

    await viewModel.deny()
    try await viewModel.denyTask?.value

    XCTAssertFalse(viewModel.showLoadingMessage)
    XCTAssertEqual(router.calledPresentationResultState, .deny)
    XCTAssertTrue(denyPresentationUseCase.executeRequestObjectErrorCalled)
    XCTAssertEqual(denyPresentationUseCase.executeRequestObjectErrorReceivedArguments?.error, .clientRejected)
    XCTAssertFalse(submitPresentationUseCase.executeContextCalled)
  }

  // MARK: Private

  // swiftlint:disable all
  private var viewModel: PresentationRequestReviewViewModel!
  private var context: PresentationRequestContext!
  private var submitPresentationUseCase = SubmitPresentationUseCaseProtocolSpy()
  private var denyPresentationUseCase = DenyPresentationUseCaseProtocolSpy()
  private var getVerifierDisplayUseCase = GetVerifierDisplayUseCaseProtocolSpy()
  private var router = MockPresentationRouter()
  private var mockTrustedVerifierDisplay = VerifierDisplay(name: "name", logo: Data(), trustStatus: .verified)
  private var mockUnTrustedVerifierDisplay = VerifierDisplay(name: "name", logo: Data(), trustStatus: .unverified)
  // swiftlint:enable all
}
