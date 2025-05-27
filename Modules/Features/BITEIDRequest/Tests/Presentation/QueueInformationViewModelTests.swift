import XCTest
@testable import BITEIDRequest

@MainActor
class QueueInformationViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    router = MockEIDRequestRouter()
    viewModel = QueueInformationViewModel(router: router, onlineSessionStartDate: Date())
  }

  func testInitialState() {
    XCTAssertNotNil(viewModel.expectedOnlineSessionStart)
  }

  func testPrimaryAction() {
    viewModel.primaryAction()
    XCTAssertTrue(router.closeCalled)
  }

  // MARK: Private

  // swiftlint:disable all
  private var router: MockEIDRequestRouter!
  private var viewModel: QueueInformationViewModel!
  // swiftlint:enable all

}
