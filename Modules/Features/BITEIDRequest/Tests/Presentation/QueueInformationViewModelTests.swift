// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import XCTest
@testable import BITEIDRequest

@MainActor
class QueueInformationViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    router = MockEIDRequestRouter()
  }

  func testInitialState() {
    viewModel = QueueInformationViewModel(router: router, onlineSessionStartDate: mockDate)

    XCTAssertEqual(viewModel.expectedOnlineSessionStart, mockDate.longDateFormat)
  }

  func testPrimaryAction() {
    viewModel = QueueInformationViewModel(router: router, onlineSessionStartDate: mockDate)
    viewModel.primaryAction()

    XCTAssertTrue(router.closeCalled)
  }

  // MARK: Private

  private let mockDate = Date()
  private var router: MockEIDRequestRouter!
  private var viewModel: QueueInformationViewModel!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
