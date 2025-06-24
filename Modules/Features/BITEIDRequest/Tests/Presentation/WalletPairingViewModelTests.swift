// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try
import Factory
import XCTest
@testable import BITEIDRequest

class WalletPairingViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    router = MockEIDRequestRouter()
    router.context.identityType = .identityCard

    viewModel = WalletPairingViewModel(router: router)
  }

  func testPrimaryAction_withIdentityType_closeRouter() {
    viewModel.primaryAction()
    XCTAssertTrue(router.closeCalled)
  }

  func testPrimaryAction_IdentityTypeIsNil_routeToDocumentSelection() {
    router.context.identityType = nil

    viewModel.primaryAction()
    XCTAssertTrue(router.documentSelectionCalled)
  }

  func testClose() {
    viewModel.close()
    XCTAssertTrue(router.closeCalled)
  }

  // MARK: Private

  private var router: MockEIDRequestRouter!
  private var viewModel: WalletPairingViewModel!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_try
