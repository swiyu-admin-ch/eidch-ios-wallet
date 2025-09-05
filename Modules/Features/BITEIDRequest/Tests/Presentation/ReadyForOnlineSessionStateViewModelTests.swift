// swiftlint:disable all
import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

@MainActor
class ReadyForOnlineSessionStateViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    delegate = RequestCaseViewStateDelegateSpy()
  }

  func testInit_validRequestCase_success() throws {
    viewModel = try ReadyForOnlineSessionStateViewModel(requestCase: mockEidRequestCase, delegate: delegate)

    XCTAssertEqual(viewModel.fullName, "\(mockEidRequestCase.firstName) \(mockEidRequestCase.lastName)")
    XCTAssertEqual(viewModel.onlineSessionStartTimeoutAt, mockEidRequestCase.state?.onlineSessionStartTimeoutAt)
    XCTAssertEqual(viewModel.formattedDate, mockEidRequestCase.state?.onlineSessionStartTimeoutAt?.longDateFormat)
    XCTAssertEqual(viewModel.requestCaseId, mockEidRequestCase.id)
    XCTAssertNotNil(viewModel.delegate)
  }

  func testInit_invalidRequestCase_success() throws {
    XCTAssertThrowsError(try ReadyForOnlineSessionStateViewModel(requestCase: .Mock.sampleInQueue, delegate: delegate)) { error in
      XCTAssertEqual(error as? RequestCaseViewStateError, .invalidState)
    }
  }

  func testPrimaryAction() async throws {
    viewModel = try ReadyForOnlineSessionStateViewModel(requestCase: mockEidRequestCase, delegate: delegate)

    viewModel.primaryAction()

    XCTAssertEqual(delegate.didStartAutoVerificationCaseIdReceivedCaseId, mockEidRequestCase.id)
  }

  // MARK: Private

  private let mockEidRequestCase: EIDRequestCase = .Mock.sampleAVReady
  private var delegate: RequestCaseViewStateDelegateSpy!
  private var viewModel: ReadyForOnlineSessionStateViewModel!
}

// swiftlint:enable all
