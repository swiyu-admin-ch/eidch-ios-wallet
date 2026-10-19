import Factory
import NavigatorUI
import XCTest
@testable import BITCore
@testable import BITCredential
@testable import BITOpenID
@testable import BITPresentation
@testable import BITTestingCore

// swiftlint:disable force_unwrapping implicitly_unwrapped_optional

@MainActor
final class NoCompatibleCredentialViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() async throws {
    try await super.setUp()
    Container.shared.preferredUserLanguageCodes.register { ["en"] }
    let declinePresentationUseCase = DeclinePresentationUseCaseProtocolSpy()
    self.declinePresentationUseCase = declinePresentationUseCase
    Container.shared.declinePresentationUseCase.register { @MainActor in declinePresentationUseCase }
    viewModel = NoCompatibleCredentialViewModel(context: context)
  }

  override func tearDown() async throws {
    Container.shared.reset()
    try await super.tearDown()
  }

  func testVerifierDisplay_oneLanguage_returnsDisplayInLanguage() throws {
    XCTAssertEqual(viewModel.verifierDisplay.name, "entityName en-US")
    XCTAssertEqual(try String(data: XCTUnwrap(viewModel.verifierDisplay.logo), encoding: .utf8), "EN_logoUri")
    XCTAssertEqual(viewModel.verifierDisplay.trustInformation, context.trustInformation)
  }

  func testDeclineRequest_success() async {
    await viewModel.declineRequest(Navigator(configuration: NavigationConfiguration()))

    XCTAssertEqual(declinePresentationUseCase.callAsFunctionContextCallsCount, 1)
    XCTAssertEqual(declinePresentationUseCase.callAsFunctionContextReceivedContext, context)
    XCTAssertNil(viewModel.destination)
  }

  func testDeclineRequest_withRedirectUri_navigatesToResultStateView() async {
    let presentationResponse = PresentationResponse(redirectUri: redirectUri)
    declinePresentationUseCase.callAsFunctionContextReturnValue = presentationResponse

    await viewModel.declineRequest(Navigator(configuration: NavigationConfiguration()))

    XCTAssertEqual(
      viewModel.destination,
      .resultState(.deny(presentationResponse), context))
  }

  func testDeclineRequest_invalidRedirectUri_presentsErrorView() async {
    declinePresentationUseCase.callAsFunctionContextThrowableError = PresentationResponseValidationError.invalidRedirectUri

    await viewModel.declineRequest(Navigator(configuration: NavigationConfiguration()))

    XCTAssertEqual(viewModel.destination, .error(.invalidRedirectUri, nil))
  }

  func testDeclineRequest_useCaseThrowsError_retry() async {
    declinePresentationUseCase.callAsFunctionContextThrowableError = TestingError.error

    await viewModel.declineRequest(Navigator(configuration: NavigationConfiguration()))

    XCTAssertEqual(declinePresentationUseCase.callAsFunctionContextCallsCount, 1)
  }

  // MARK: Private

  private let context = PresentationRequestContext.Mock.vcSdJwtSample
  private let redirectUri = URL(string: "https://verifier.ch")!

  private var viewModel: NoCompatibleCredentialViewModel!
  private var declinePresentationUseCase: DeclinePresentationUseCaseProtocolSpy!
}
