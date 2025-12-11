import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

// swiftlint:disable all

@MainActor
class WalletPairingStateViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    delegate = RequestCaseViewStateDelegateSpy()
  }

  func testPrimaryAction() async throws {
    viewModel = try WalletPairingStateViewModel(requestCase: mockEidRequestCase, delegate: delegate)

    viewModel.primaryAction()

    XCTAssertEqual(delegate.didTapWalletPairingCaseIdReceivedCaseId, mockEidRequestCase.id)
  }

  // MARK: Private

  private let mockEidRequestCase: EIDRequestCase = .Mock.sampleWalletPairing
  private var delegate: RequestCaseViewStateDelegateSpy!
  private var viewModel: WalletPairingStateViewModel!
}
