import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

// swiftlint:disable all

@MainActor
class AutoVerificationStateViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    delegate = RequestCaseViewStateDelegateSpy()
  }

  func testPrimaryAction() throws {
    viewModel = try AutoVerificationStateViewModel(requestCase: mockEidRequestCase, delegate: delegate)

    viewModel.primaryAction()

    XCTAssertEqual(delegate.didTapIdentityCheckCaseIdReceivedCaseId, mockEidRequestCase.id)
  }

  // MARK: Private

  private let mockEidRequestCase: EIDRequestCase = .Mock.sampleAutoVerification
  private var delegate: RequestCaseViewStateDelegateSpy!
  private var viewModel: AutoVerificationStateViewModel!
}
