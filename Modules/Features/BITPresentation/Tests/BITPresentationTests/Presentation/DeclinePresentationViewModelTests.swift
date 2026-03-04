import Factory
import XCTest
@testable import BITCredential
@testable import BITOpenID
@testable import BITPresentation
@testable import BITTestingCore

// swiftlint:disable force_unwrapping implicitly_unwrapped_optional

@MainActor
final class DeclinePresentationViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    registerMocks()
    viewModel = DeclinePresentationViewModel(context: context, router: router)
  }

  func testVerifierDisplay_oneLanguage_returnsDisplayInLanguage() throws {
    Container.shared.preferredUserLanguageCodes.register { ["en"] }

    viewModel = DeclinePresentationViewModel(context: context, router: router)

    XCTAssertEqual(viewModel.verifierDisplay.name, "EN entityName")
    XCTAssertEqual(try String(data: XCTUnwrap(viewModel.verifierDisplay.logo), encoding: .utf8), "EN_logoUri")
    XCTAssertEqual(viewModel.verifierDisplay.trustInformation, context.trustInformation)
  }

  func testDeclineRequest_success() async {
    await viewModel.declineRequest()

    XCTAssertEqual(declinePresentationUseCase.callAsFunctionUrlCallsCount, 1)
    XCTAssertEqual(declinePresentationUseCase.callAsFunctionUrlReceivedUrl, context.responseUri)

    XCTAssertTrue(router.closeCalled)
  }

  func testDeclineRequest_useCaseThrowsError_retry() async {
    declinePresentationUseCase.callAsFunctionUrlThrowableError = TestingError.error

    await viewModel.declineRequest()

    XCTAssertTrue(presentationFinishDelegateMock.retryCalled)
  }

  // MARK: Private

  private var viewModel: DeclinePresentationViewModel!
  private var router: MockPresentationRouter!
  private var presentationFinishDelegateMock: MockPresentationFinishDelegate!
  private var declinePresentationUseCase: DeclinePresentationUseCaseProtocolSpy!

  private let context = PresentationRequestContext.Mock.vcSdJwtWithIdentityTrust

  private func registerMocks() {
    declinePresentationUseCase = DeclinePresentationUseCaseProtocolSpy()
    presentationFinishDelegateMock = MockPresentationFinishDelegate()

    Container.shared.declinePresentationUseCase.register { self.declinePresentationUseCase }
    Container.shared.declinePresentationRequestDelay.register { 0 }

    router = MockPresentationRouter()
    router.delegate = presentationFinishDelegateMock
  }
}
