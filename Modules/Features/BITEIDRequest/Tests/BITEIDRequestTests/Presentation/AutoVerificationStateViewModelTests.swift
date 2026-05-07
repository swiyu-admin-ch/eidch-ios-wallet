// swiftlint:disable all
import BITL10n
import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

@MainActor
class AutoVerificationStateViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    delegate = RequestCaseViewStateDelegateSpy()
  }

  func testInit_filesNotSubmitted_success() throws {
    viewModel = try AutoVerificationStateViewModel(requestCase: mockEidRequestCase, delegate: delegate)

    XCTAssertEqual(viewModel.id, mockEidRequestCase.id)
    XCTAssertEqual(viewModel.fullName, "\(mockEidRequestCase.firstName) \(mockEidRequestCase.lastName)")
    XCTAssertEqual(viewModel.filesSubmitted, false)
    XCTAssertEqual(viewModel.notificationTitle, L10n.tkEidRequestNotificationWalletPairingPrimary)
    XCTAssertEqual(viewModel.notificationContent, L10n.tkEidRequestNotificationWalletPairingSecondary)
    XCTAssertEqual(viewModel.primaryActionLabel, L10n.tkEidRequestNotificationWalletPairingButton)
    XCTAssertNotNil(viewModel.delegate)
  }

  func testInit_filesSubmitted_success() throws {
    var requestCase = mockEidRequestCase
    requestCase.filesSubmitted = true

    viewModel = try AutoVerificationStateViewModel(requestCase: requestCase, delegate: delegate)

    XCTAssertEqual(viewModel.id, requestCase.id)
    XCTAssertEqual(viewModel.fullName, "\(requestCase.firstName) \(requestCase.lastName)")
    XCTAssertEqual(viewModel.filesSubmitted, true)
    XCTAssertEqual(viewModel.notificationTitle, L10n.tkEidRequestNotificationAutoVerificationFilesSubmittedPrimary(viewModel.fullName))
    XCTAssertEqual(viewModel.notificationContent, L10n.tkEidRequestNotificationAutoVerificationFilesSubmittedSecondary)
    XCTAssertEqual(viewModel.primaryActionLabel, L10n.tkEidRequestNotificationWalletPairingButton)
    XCTAssertNotNil(viewModel.delegate)
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
