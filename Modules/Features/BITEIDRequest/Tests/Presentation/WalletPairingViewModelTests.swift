import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try

final class WalletPairingViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    router = MockEIDRequestRouter()
    router.context.caseId = "caseId"

    registerMocks()
    viewModel = WalletPairingViewModel(router: router)
  }

  func testPrimaryAction_success() async {
    await viewModel.primaryAction()

    XCTAssertTrue(router.avIdentityCheckCalled)

    XCTAssertEqual(startOnlineSessionUseCase.executeForCallsCount, 1)
    XCTAssertEqual(startOnlineSessionUseCase.executeForReceivedCaseId, router.context.caseId)

    XCTAssertEqual(pairWalletUseCase.executeForCallsCount, 1)
    XCTAssertEqual(pairWalletUseCase.executeForReceivedCaseId, router.context.caseId)
  }

  func testPrimaryAction_missingCaseId_routeToError() async {
    router.context.caseId = nil

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

    XCTAssertTrue(router.avIdentityCheckCalled)
  }

  func testSecondaryAction_success() async {
    await viewModel.secondaryAction()

    XCTAssertTrue(router.walletPairingListCalled)
    XCTAssertEqual(startOnlineSessionUseCase.executeForCallsCount, 1)
    XCTAssertEqual(startOnlineSessionUseCase.executeForReceivedCaseId, router.context.caseId)
  }

  func testSecondaryAction_missingCaseId_routeToError() async {
    router.context.caseId = nil

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

    XCTAssertTrue(router.walletPairingListCalled)
  }

  func testClose() {
    viewModel.close()
    XCTAssertTrue(router.closeCalled)
  }

  // MARK: Private

  private let mockPairingId = "mockPairingId"
  private var router: MockEIDRequestRouter!
  private var viewModel: WalletPairingViewModel!
  private var pairWalletUseCase: PairWalletUseCaseProtocolSpy!
  private var startOnlineSessionUseCase: StartOnlineSessionUseCaseProtocolSpy!

  private func registerMocks() {
    pairWalletUseCase = PairWalletUseCaseProtocolSpy()
    pairWalletUseCase.executeForReturnValue = mockPairingId
    startOnlineSessionUseCase = StartOnlineSessionUseCaseProtocolSpy()

    Container.shared.pairWalletUseCase.register { self.pairWalletUseCase }
    Container.shared.startOnlineSessionUseCase.register { self.startOnlineSessionUseCase }
  }
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_try
