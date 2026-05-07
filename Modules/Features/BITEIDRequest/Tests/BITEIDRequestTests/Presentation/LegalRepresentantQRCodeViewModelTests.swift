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
    context = EIDRequestContext()
    context.caseId = mockCaseId
    Container.shared.eidRequestContext.register { @MainActor in self.context }

    getLegalRepresentantVerificationQRCodeUseCase = GetLegalRepresentantVerificationQRCodeUseCaseProtocolSpy()
    updateEIDRequestCaseStatusUseCase = UpdateEIDRequestCaseStatusUseCaseProtocolSpy()

    Container.shared.getLegalRepresentantVerificationQRCodeUseCase.register { @MainActor in self.getLegalRepresentantVerificationQRCodeUseCase }
    Container.shared.updateEIDRequestCaseStatusUseCase.register { @MainActor in self.updateEIDRequestCaseStatusUseCase }

    viewModel = LegalRepresentantQRCodeViewModel(caseId: mockCaseId)
  }

  func initialState() {
    XCTAssertTrue(viewModel.isShareQRCodeDisabled)
    XCTAssertEqual(viewModel.state, .loading)
  }

  func testGetVerificationQRCode_happyPath() async throws {
    getLegalRepresentantVerificationQRCodeUseCase.executeForReturnValue = try (Data(), XCTUnwrap(URL(string: "mock")))

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

    if case .legalRepresentantConsentState = viewModel.destination {
      XCTAssert(true)
    } else {
      XCTFail("Expected legalRepresentantConsentState case")
    }
  }

  // MARK: Private

  private let mockCaseId = "caseId"

  private var viewModel: LegalRepresentantQRCodeViewModel!
  private var getLegalRepresentantVerificationQRCodeUseCase: GetLegalRepresentantVerificationQRCodeUseCaseProtocolSpy!
  private var updateEIDRequestCaseStatusUseCase: UpdateEIDRequestCaseStatusUseCaseProtocolSpy!
  private var context: EIDRequestContext!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
