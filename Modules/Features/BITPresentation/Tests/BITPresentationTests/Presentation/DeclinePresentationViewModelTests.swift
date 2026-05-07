import Factory
import NavigatorUI
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
    viewModel = DeclinePresentationViewModel(context: context)
  }

  func testVerifierDisplay_oneLanguage_returnsDisplayInLanguage() throws {
    Container.shared.preferredUserLanguageCodes.register { ["en"] }

    viewModel = DeclinePresentationViewModel(context: context)

    XCTAssertEqual(viewModel.verifierDisplay.name, "EN entityName")
    XCTAssertEqual(try String(data: XCTUnwrap(viewModel.verifierDisplay.logo), encoding: .utf8), "EN_logoUri")
    XCTAssertEqual(viewModel.verifierDisplay.trustInformation, context.trustInformation)
  }

  func testDeclineRequest_success() async {
    await viewModel.declineRequest(Navigator(configuration: NavigationConfiguration()))

    XCTAssertEqual(declinePresentationUseCase.callAsFunctionContextCallsCount, 1)
    XCTAssertEqual(declinePresentationUseCase.callAsFunctionContextReceivedContext, context)
  }

  func testDeclineRequest_useCaseThrowsError_retry() async {
    declinePresentationUseCase.callAsFunctionContextThrowableError = TestingError.error

    await viewModel.declineRequest(Navigator(configuration: NavigationConfiguration()))

    XCTAssertEqual(declinePresentationUseCase.callAsFunctionContextCallsCount, 1)
  }

  // MARK: Private

  private var viewModel: DeclinePresentationViewModel!
  private var declinePresentationUseCase: DeclinePresentationUseCaseProtocolSpy!

  private let context = PresentationRequestContext.Mock.vcSdJwtWithIdentityTrust

  private func registerMocks() {
    declinePresentationUseCase = DeclinePresentationUseCaseProtocolSpy()

    Container.shared.declinePresentationUseCase.register { @MainActor in self.declinePresentationUseCase }
    Container.shared.declinePresentationRequestDelay.register { 0 }
  }
}
