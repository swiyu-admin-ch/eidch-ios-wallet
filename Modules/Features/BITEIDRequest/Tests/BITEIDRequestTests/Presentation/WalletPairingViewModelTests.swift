import BITTheming
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

    if case .avIdentityCheck(let caseId) = viewModel.destination {
      XCTAssertEqual(caseId, mockCaseId)
    }

    XCTAssertEqual(startOnlineSessionUseCase.executeForCallsCount, 1)
    XCTAssertEqual(startOnlineSessionUseCase.executeForReceivedCaseId, context.caseId)

    XCTAssertEqual(pairWalletUseCase.executeForCallsCount, 1)
    XCTAssertEqual(pairWalletUseCase.executeForReceivedCaseId, context.caseId)
  }

  func testPrimaryAction_missingCaseId_routeToError() async {
    context.caseId = nil

    await viewModel.primaryAction()

    assertError(EIDRequestError.missingCaseId)
  }

  func testPrimaryAction_startOnlineSessionThrowsError_routeToError() async {
    startOnlineSessionUseCase.executeForThrowableError = TestingError.error

    await viewModel.primaryAction()

    assertError(TestingError.error)
  }

  func testPrimaryAction_pairWalletThrowsError_routeToError() async {
    pairWalletUseCase.executeForThrowableError = TestingError.error

    await viewModel.primaryAction()

    assertError(TestingError.error)
  }

  func testSecondaryAction_success() async {
    await viewModel.secondaryAction()

    if case .walletPairingList(let caseId) = viewModel.destination {
      XCTAssertEqual(caseId, mockCaseId)
    }

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

  func testSecondaryAction_startOnlineSessionThrowsInvalidStateError_routeToWalletPairingList() async {
    startOnlineSessionUseCase.executeForThrowableError = EIDRequestRepository.Error.invalidState

    await viewModel.secondaryAction()

    if case .walletPairingList(let caseId) = viewModel.destination {
      XCTAssertEqual(caseId, mockCaseId)
    }
  }

  // MARK: Private

  private let mockCaseId = "mockCaseId"
  private let mockPairingId = "mockPairingId"

  private var context: EIDRequestContext!
  private var viewModel: WalletPairingViewModel!
  private var pairWalletUseCase: PairWalletUseCaseProtocolSpy!
  private var startOnlineSessionUseCase: StartOnlineSessionUseCaseProtocolSpy!

  private func assertError(_ error: Error) {
    if case .error(let dataset) = viewModel.destination {
      XCTAssertEqual(dataset, ErrorDataset.retry(error) { _ in })
    } else {
      XCTFail("Expected .error destination")
    }
  }

  private func registerMocks() {
    context = EIDRequestContext()
    context.caseId = mockCaseId
    pairWalletUseCase = PairWalletUseCaseProtocolSpy()
    pairWalletUseCase.executeForReturnValue = mockPairingId
    startOnlineSessionUseCase = StartOnlineSessionUseCaseProtocolSpy()

    Container.shared.eidRequestContext.register { @MainActor in self.context }
    Container.shared.pairWalletUseCase.register { @MainActor in self.pairWalletUseCase }
    Container.shared.startOnlineSessionUseCase.register { @MainActor in self.startOnlineSessionUseCase }
  }
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_try
