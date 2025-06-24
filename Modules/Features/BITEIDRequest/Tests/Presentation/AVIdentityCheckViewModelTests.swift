// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import XCTest
@testable import BITEIDRequest

class AVIdentityCheckViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    router = MockEIDRequestRouter()
    viewModel = AVIdentityCheckViewModel(router: router)
  }

  func testPrimaryAction() {
    viewModel.primaryAction()
    XCTAssertTrue(router.walletPairingCalled)
  }

  func testClose() {
    viewModel.close()
    XCTAssertTrue(router.closeCalled)
  }

  // MARK: Private

  private var router: MockEIDRequestRouter!
  private var viewModel: AVIdentityCheckViewModel!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
