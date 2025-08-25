// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try
import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITTestingCore

class WalletPairingViewModelTests: XCTestCase {

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
  }

  func testPrimaryAction_missingCaseId_routeToError() async {
    router.context.caseId = nil

    await viewModel.primaryAction()

  }

  func testPrimaryAction_startOnlineSessionThrowsError_routeToError() async {
    startOnlineSessionUseCase.executeForThrowableError = TestingError.error

    await viewModel.primaryAction()

  }

  func testClose() {
    viewModel.close()
    XCTAssertTrue(router.closeCalled)
  }

  // MARK: Private

  private var router: MockEIDRequestRouter!
  private var viewModel: WalletPairingViewModel!
  private var startOnlineSessionUseCase: StartOnlineSessionUseCaseProtocolSpy!

  private func registerMocks() {
    startOnlineSessionUseCase = StartOnlineSessionUseCaseProtocolSpy()

    Container.shared.startOnlineSessionUseCase.register { self.startOnlineSessionUseCase }
  }
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_try
