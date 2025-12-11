import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try

@MainActor
final class WalletPairingViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    registerMocks()
    viewModel = WalletPairingViewModel()
  }

  func testPrimaryAction_success() async {
    await viewModel.primaryAction()

    XCTAssertEqual(viewModel.destination, .avIdentityCheck)

    XCTAssertEqual(startOnlineSessionUseCase.executeForCallsCount, 1)
    XCTAssertEqual(startOnlineSessionUseCase.executeForReceivedCaseId, context.caseId)

    XCTAssertEqual(pairWalletUseCase.executeForCallsCount, 1)
    XCTAssertEqual(pairWalletUseCase.executeForReceivedCaseId, context.caseId)
  }

  func testPrimaryAction_missingCaseId_routeToError() async {
    context.caseId = nil

    await viewModel.primaryAction()

    #warning("TODO: XCTAssert error case here when implemented")
  }

  func testPrimaryAction_startOnlineSessionThrowsError_routeToError() async {
    startOnlineSessionUseCase.executeForThrowableError = TestingError.error

    await viewModel.primaryAction()

    #warning("TODO: XCTAssert error case here")
  }

  func testPrimaryAction_startOnlineSessionThrowsInvalidStateError_routeToIdentityCheck() async throws {
    startOnlineSessionUseCase.executeForThrowableError = EIDRequestRepository.Error.invalidState

    await viewModel.primaryAction()

    XCTAssertEqual(viewModel.destination, .avIdentityCheck)
  }

  func testSecondaryAction_success() async {
    await viewModel.secondaryAction()

    XCTAssertEqual(viewModel.destination, .walletPairingList)
    XCTAssertEqual(startOnlineSessionUseCase.executeForCallsCount, 1)
    XCTAssertEqual(startOnlineSessionUseCase.executeForReceivedCaseId, context.caseId)
  }

  func testSecondaryAction_missingCaseId_routeToError() async {
    context.caseId = nil

    await viewModel.secondaryAction()

    #warning("TODO: XCTAssert error case here")
  }

  func testSecondaryAction_startOnlineSessionThrowsError_routeToError() async {
    startOnlineSessionUseCase.executeForThrowableError = TestingError.error

    await viewModel.secondaryAction()

    #warning("TODO: XCTAssert error case here")
  }

  func testSecondaryAction_startOnlineSessionThrowsInvalidStateError_routeToWalletPairingList() async throws {
    startOnlineSessionUseCase.executeForThrowableError = EIDRequestRepository.Error.invalidState

    await viewModel.secondaryAction()

    XCTAssertEqual(viewModel.destination, .walletPairingList)
  }

  func testClose() {
    viewModel.navigationClose()
    XCTAssertTrue(viewModel.isNavigationCloseTriggered)
  }

  // MARK: Private

  private let mockPairingId = "mockPairingId"

  private var context: EIDRequestContext!
  private var viewModel: WalletPairingViewModel!
  private var pairWalletUseCase: PairWalletUseCaseProtocolSpy!
  private var startOnlineSessionUseCase: StartOnlineSessionUseCaseProtocolSpy!

  private func registerMocks() {
    context = EIDRequestContext()
    context.caseId = "caseId"
    pairWalletUseCase = PairWalletUseCaseProtocolSpy()
    pairWalletUseCase.executeForReturnValue = mockPairingId
    startOnlineSessionUseCase = StartOnlineSessionUseCaseProtocolSpy()

    Container.shared.eidRequestContext.register { self.context }
    Container.shared.pairWalletUseCase.register { self.pairWalletUseCase }
    Container.shared.startOnlineSessionUseCase.register { self.startOnlineSessionUseCase }
  }
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_try
