// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import XCTest
@testable import BITEIDRequest

class AVWelcomeViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {

    viewModel = AVWelcomeViewModel()
  }

  func testPrimaryAction() {
    viewModel.primaryAction()
    XCTAssertEqual(viewModel.destination, .walletPairing)
  }

  // MARK: Private

  private var viewModel: AVWelcomeViewModel!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
