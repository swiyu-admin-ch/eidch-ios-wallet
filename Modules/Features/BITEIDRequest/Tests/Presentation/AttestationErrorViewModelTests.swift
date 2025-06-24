// swiftlint:disable implicitly_unwrapped_optional force_unwrapping weak_delegate
import XCTest
@testable import BITEIDRequest

class AttestationErrorViewModelTests: XCTestCase {

  // MARK: Internal

  @MainActor
  override func setUp() {
    router = MockEIDRequestRouter()
    delegate = AttestationErrorDelegateSpy()
    viewModel = AttestationErrorViewModel(router: router, delegate: delegate)
  }

  @MainActor
  func testPrimaryAction() {
    viewModel.primaryAction()

    XCTAssertTrue(router.popCalled)
    XCTAssertTrue(delegate.didTapPrimaryActionCalled)
  }

  @MainActor
  func testSecondaryAction() {
    viewModel.secondaryAction()
    XCTAssertTrue(router.closeCalled)
  }

  // MARK: Private

  private var router: MockEIDRequestRouter!
  private var viewModel: AttestationErrorViewModel!
  private var delegate: AttestationErrorDelegateSpy!

}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping weak_delegate
