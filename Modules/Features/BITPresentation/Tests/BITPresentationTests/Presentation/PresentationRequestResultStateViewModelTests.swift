// swiftlint:disable force_unwrapping implicitly_unwrapped_optional
import Factory
import XCTest
@testable import BITCredential
@testable import BITOpenID
@testable import BITPresentation

class PresentationRequestResultStateViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
  }

  @MainActor
  func testVerifierDisplay_oneLanguage_returnsDisplayInLanguage() throws {
    Container.shared.preferredUserLanguageCodes.register { ["en"] }

    let viewModel = PresentationRequestResultStateViewModel(state: .error, context: context)

    XCTAssertEqual(viewModel.verifierDisplay.name, "entityName en-US")
    XCTAssertEqual(try String(data: XCTUnwrap(viewModel.verifierDisplay.logo), encoding: .utf8), "EN_logoUri")
    XCTAssertEqual(viewModel.verifierDisplay.trustInformation, context.trustInformation)
  }

  @MainActor
  func testRetry_delegateRetryCalled() {
    let viewModel = PresentationRequestResultStateViewModel(state: .error, context: context)

    XCTAssertFalse(viewModel.isNavigationBackTriggered)
    viewModel.retry()

    XCTAssertTrue(viewModel.isNavigationBackTriggered)
  }

  // MARK: Private

  private let context = PresentationRequestContext.Mock.vcSdJwtSample
  // swiftlint:enable all
}
