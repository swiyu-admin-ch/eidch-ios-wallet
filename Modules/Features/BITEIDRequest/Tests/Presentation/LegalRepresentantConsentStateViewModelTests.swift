// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import BITL10n
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared

@MainActor
class LegalRepresentantConsentStateViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {

  }

  func testInit_inQueueState_legalRepresentantVerified() throws {
    let requestCase = EIDRequestCase.Mock.sampleInQueue
    let requestCaseViewState = try RequestCaseViewState(requestCase)

    viewModel = LegalRepresentantConsentStateViewModel(state: requestCaseViewState)

    XCTAssertEqual(viewModel.primaryText, L10n.tkEidRequestConsentOkAvQueuePrimary)
    XCTAssertEqual(viewModel.secondaryText, L10n.tkEidRequestConsentOkAvQueueSecondary)
    XCTAssertEqual(viewModel.primaryButtonText, L10n.tkGlobalClose)
  }

  func testInit_inQueueState_legalRepresentantNotVerified() throws {
    let requestCase = EIDRequestCase.Mock.sampleInQueueNotVerified
    let requestCaseViewState = try RequestCaseViewState(requestCase)

    viewModel = LegalRepresentantConsentStateViewModel(state: requestCaseViewState)

    XCTAssertEqual(viewModel.primaryText, L10n.tkEidRequestLegalRepresentantPendingConsentInQueuePrimary)
    XCTAssertEqual(viewModel.secondaryText, L10n.tkEidRequestLegalRepresentantPendingConsentInQueueSecondary)
    XCTAssertEqual(viewModel.primaryButtonText, L10n.tkGlobalClose)
  }

  func testInit_readyForAVState_legalRepresentantVerified() throws {
    let requestCase = EIDRequestCase.Mock.sampleAVReady
    let requestCaseViewState = try RequestCaseViewState(requestCase)

    viewModel = LegalRepresentantConsentStateViewModel(state: requestCaseViewState)

    XCTAssertEqual(viewModel.primaryText, L10n.tkEidRequestLegalRepresentantGivenConsentReadyForAVPrimary)
    XCTAssertEqual(viewModel.primaryButtonText, L10n.tkEidRequestLegalRepresentantPendingConsentStartButton)
  }

  func testInit_readyForAVState_legalRepresentantNotVerified() throws {
    let requestCase = EIDRequestCase.Mock.sampleAVReadyNotVerified
    let requestCaseViewState = try RequestCaseViewState(requestCase)

    viewModel = LegalRepresentantConsentStateViewModel(state: requestCaseViewState)

    XCTAssertEqual(viewModel.primaryButtonText, L10n.tkGlobalClose)
    XCTAssertEqual(viewModel.primaryText, L10n.tkEidRequestLegalRepresentantPendingConsentReadyForAVPrimary)
  }

  func testInit_expired() throws {
    let requestCase = EIDRequestCase.Mock.sampleExpired
    let requestCaseViewState = try RequestCaseViewState(requestCase)

    viewModel = LegalRepresentantConsentStateViewModel(state: requestCaseViewState)

    XCTAssertEqual(viewModel.primaryText, L10n.tkEidRequestLegalRepresentantPendingConsentExpiredPrimary)
    XCTAssertEqual(viewModel.secondaryText, L10n.tkEidRequestLegalRepresentantPendingConsentExpiredSecondary)
    XCTAssertEqual(viewModel.primaryButtonText, L10n.tkGlobalClose)
  }

  func testPrimaryAction_readyForOnlineSessionStateVerified_routeToIDCheck() throws {
    let requestCase = EIDRequestCase.Mock.sampleAVReady
    let requestCaseViewState = try RequestCaseViewState(requestCase)

    viewModel = LegalRepresentantConsentStateViewModel(state: requestCaseViewState)
    viewModel.primaryAction()

    XCTAssertEqual(viewModel.destination, .avIdentityCheck)
  }

  func testPrimaryAction_inQueueState_close() throws {
    let requestCase = EIDRequestCase.Mock.sampleInQueue
    let requestCaseViewState = try RequestCaseViewState(requestCase)

    viewModel = LegalRepresentantConsentStateViewModel(state: requestCaseViewState)
    viewModel.primaryAction()

    XCTAssertTrue(viewModel.isNavigationCloseTriggered)
  }

  // MARK: Private

  private var viewModel: LegalRepresentantConsentStateViewModel!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
