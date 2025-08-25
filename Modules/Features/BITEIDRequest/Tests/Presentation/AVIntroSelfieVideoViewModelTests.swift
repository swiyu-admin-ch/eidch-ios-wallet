// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import XCTest
@testable import BITEIDRequest

class AVIntroSelfieVideoViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    router = MockEIDRequestRouter()
    viewModel = AVIntroSelfieVideoViewModel(router: router)
  }

  func testPrimaryAction() {
    viewModel.primaryAction()
    XCTAssertTrue(router.recordSelfieCalled)
  }

  func testClose() {
    viewModel.close()
    XCTAssertTrue(router.closeCalled)
  }

  // MARK: Private

  private var router: MockEIDRequestRouter!
  private var viewModel: AVIntroSelfieVideoViewModel!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
