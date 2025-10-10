// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

@MainActor
class LegalRepresentantQRCodeViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    router = MockEIDRequestRouter()
    router.context.caseId = mockCaseId
    getLegalRepresentantVerificationQRCodeUseCase = GetLegalRepresentantVerificationQRCodeUseCaseProtocolSpy()
    updateEIDRequestCaseStatusUseCase = UpdateEIDRequestCaseStatusUseCaseProtocolSpy()

    Container.shared.getLegalRepresentantVerificationQRCodeUseCase.register { self.getLegalRepresentantVerificationQRCodeUseCase }
    Container.shared.updateEIDRequestCaseStatusUseCase.register { self.updateEIDRequestCaseStatusUseCase }

    viewModel = LegalRepresentantQRCodeViewModel(router: router, caseId: mockCaseId)
  }

  func initialState() {
    XCTAssertTrue(viewModel.isShareQRCodeDisabled)
    XCTAssertEqual(viewModel.state, .loading)
  }

  func testGetVerificationQRCode_happyPath() async {
    getLegalRepresentantVerificationQRCodeUseCase.executeForReturnValue = (Data(), URL(string: "mock")!)

    await viewModel.getVerificationQRCode()

    if case .result(let data, let url) = viewModel.state {
      XCTAssertEqual(viewModel.state, .result(data, url))
    }

    XCTAssertFalse(viewModel.isShareQRCodeDisabled)
    XCTAssertEqual(getLegalRepresentantVerificationQRCodeUseCase.executeForReceivedCaseId, mockCaseId)
  }

  func testGetVerificationQRCode_failurePath() async {
    getLegalRepresentantVerificationQRCodeUseCase.executeForThrowableError = TestingError.error

    await viewModel.getVerificationQRCode()

    XCTAssertEqual(viewModel.state, .error)
    XCTAssertTrue(viewModel.isShareQRCodeDisabled)
  }

  func testFinish_success_routeToConsentState() async throws {
    let mockRequestCase = EIDRequestCase.Mock.sampleInQueue
    let mockRequestCaseStateView = try RequestCaseViewState(mockRequestCase)
    updateEIDRequestCaseStatusUseCase.executeForReturnValue = mockRequestCase

    await viewModel.finish()

    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeForReceivedRequestCaseId, mockCaseId)
    XCTAssertEqual(updateEIDRequestCaseStatusUseCase.executeForCallsCount, 1)
    XCTAssertEqual(router.legalRepresentantConsentStateArgument, mockRequestCaseStateView)
  }

  func testFinish_updateRequestCaseFails_close() async {
    updateEIDRequestCaseStatusUseCase.executeForThrowableError = TestingError.error

    await viewModel.finish()

    XCTAssertTrue(router.closeCalled)
  }

  func testFinish_unknownState_close() async throws {
    updateEIDRequestCaseStatusUseCase.executeForReturnValue = EIDRequestCase.Mock.sampleWithoutState

    await viewModel.finish()

    XCTAssertTrue(router.closeCalled)
  }

  // MARK: Private

  private let mockCaseId = "caseId"
  private var router: MockEIDRequestRouter!
  private var viewModel: LegalRepresentantQRCodeViewModel!
  private var getLegalRepresentantVerificationQRCodeUseCase: GetLegalRepresentantVerificationQRCodeUseCaseProtocolSpy!
  private var updateEIDRequestCaseStatusUseCase: UpdateEIDRequestCaseStatusUseCaseProtocolSpy!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
