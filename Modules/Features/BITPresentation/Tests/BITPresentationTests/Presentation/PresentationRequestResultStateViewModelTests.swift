// swiftlint:disable force_unwrapping implicitly_unwrapped_optional
import Factory
import XCTest
@testable import BITCredential
@testable import BITOpenID
@testable import BITPresentation

class PresentationRequestResultStateViewModelTests: XCTestCase {

  // MARK: Internal

  @MainActor
  override func setUp() {
    Container.shared.reset()

    viewModel = PresentationRequestResultStateViewModel(state: .error, context: context)
  }

  @MainActor
  func testVerifierDisplay_oneLanguage_returnsDisplayInLanguage() throws {
    Container.shared.preferredUserLanguageCodes.register { ["en"] }

    viewModel = PresentationRequestResultStateViewModel(state: .error, context: context)

    XCTAssertEqual(viewModel.verifierDisplay.name, "entityName en-US")
    XCTAssertEqual(try String(data: XCTUnwrap(viewModel.verifierDisplay.logo), encoding: .utf8), "EN_logoUri")
    XCTAssertEqual(viewModel.verifierDisplay.trustInformation, context.trustInformation)
  }

  @MainActor
  func testRetry_delegateRetryCalled() {
    XCTAssertFalse(viewModel.isNavigationBackTriggered)
    viewModel.retry()

    XCTAssertTrue(viewModel.isNavigationBackTriggered)
  }

  // MARK: Private

  private var viewModel: PresentationRequestResultStateViewModel!
  private let context = PresentationRequestContext.Mock.vcSdJwtSample
  // swiftlint:enable all
}
