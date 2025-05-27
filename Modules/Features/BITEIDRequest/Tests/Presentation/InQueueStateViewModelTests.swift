// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITTestingCore

@MainActor
class InQueueStateViewModelTests: XCTestCase {

  // MARK: Internal

  func testInit_validRequestCase_success() throws {
    viewModel = try InQueueStateViewModel(requestCase: mockEidRequestCase)

    XCTAssertEqual(viewModel.fullName, "\(mockEidRequestCase.firstName) \(mockEidRequestCase.lastName)")
    XCTAssertEqual(viewModel.onlineSessionStartOpenAt, mockEidRequestCase.state?.onlineSessionStartOpenAt)
    XCTAssertEqual(viewModel.formattedDate, mockEidRequestCase.state?.onlineSessionStartOpenAt?.longDateFormat)
    XCTAssertEqual(viewModel.requestCaseId, mockEidRequestCase.id)
    XCTAssertNil(viewModel.delegate)
  }

  func testInit_invalidRequestCase_success() throws {
    XCTAssertThrowsError(try InQueueStateViewModel(requestCase: .Mock.sampleAVReady)) { error in
      XCTAssertEqual(error as? RequestCaseViewStateError, .invalidState)
    }
  }

  // MARK: Private

  private let mockEidRequestCase: EIDRequestCase = .Mock.sampleInQueue
  private var viewModel: InQueueStateViewModel!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
