import XCTest
@testable import BITEIDRequest

class DataPrivacyViewModelTests: XCTestCase {

  // MARK: Internal

  @MainActor
  override func setUp() {
    router = MockEIDRequestRouter()
    viewModel = DataPrivacyViewModel(router: router)
  }

  @MainActor
  func testClose() {
    viewModel.close()
    XCTAssertTrue(router.closeCalled)
  }

  @MainActor
  func testPrimaryAction() {
    viewModel.primaryAction()
    XCTAssertTrue(router.attestationCalled)
  }

  @MainActor
  func testOpenHelp() {
    viewModel.openHelp()
    XCTAssertTrue(router.externalLinkCalled)
  }

  // MARK: Private

  // swiftlint:disable implicitly_unwrapped_optional force_unwrapping
  private var router: MockEIDRequestRouter!
  private var viewModel: DataPrivacyViewModel!
  // swiftlint:enable implicitly_unwrapped_optional force_unwrapping

}
