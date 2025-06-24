// swiftlint:disable all
import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITTestingCore

@MainActor
class InQueueStateViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    delegate = RequestCaseViewStateDelegateSpy()
  }

  func testInit_validRequestCase_success() throws {
    viewModel = try InQueueStateViewModel(requestCase: mockEidRequestCase, delegate: delegate)

    XCTAssertEqual(viewModel.fullName, "\(mockEidRequestCase.firstName) \(mockEidRequestCase.lastName)")
    XCTAssertEqual(viewModel.onlineSessionStartOpenAt, mockEidRequestCase.state?.onlineSessionStartOpenAt)
    XCTAssertEqual(viewModel.formattedDate, mockEidRequestCase.state?.onlineSessionStartOpenAt?.longDateFormat)
    XCTAssertEqual(viewModel.requestCaseId, mockEidRequestCase.id)
    XCTAssertNotNil(viewModel.delegate)
  }

  func testInit_invalidRequestCase_success() throws {
    XCTAssertThrowsError(try InQueueStateViewModel(requestCase: .Mock.sampleAVReady)) { error in
      XCTAssertEqual(error as? RequestCaseViewStateError, .invalidState)
    }
  }

  func testPrimaryAction_success() throws {
    viewModel = try InQueueStateViewModel(requestCase: mockEidRequestCase, delegate: delegate)

    viewModel.primaryAction()

    XCTAssertEqual(delegate.didTapObtainConsentCaseIdReceivedCaseId, mockEidRequestCase.id)
  }

  // MARK: Private

  private let mockEidRequestCase: EIDRequestCase = .Mock.sampleInQueue
  private var viewModel: InQueueStateViewModel!
  private var delegate: RequestCaseViewStateDelegateSpy!
}

// swiftlint:enable all
