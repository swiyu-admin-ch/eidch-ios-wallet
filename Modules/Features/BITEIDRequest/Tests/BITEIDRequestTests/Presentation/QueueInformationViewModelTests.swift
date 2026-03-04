// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import XCTest
@testable import BITEIDRequest

@MainActor
class QueueInformationViewModelTests: XCTestCase {

  // MARK: Internal

  func testInitialState() {
    viewModel = QueueInformationViewModel(onlineSessionStartDate: mockDate)

    XCTAssertEqual(viewModel.expectedOnlineSessionStart, mockDate.longDateFormat)
  }

  // MARK: Private

  private let mockDate = Date()
  private var viewModel: QueueInformationViewModel!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
