// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITTestingCore

@MainActor
class LegalRepresentantQRCodeViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    router = MockEIDRequestRouter()
    getLegalRepresentantVerificationQRCodeUseCase = GetLegalRepresentantVerificationQRCodeUseCaseProtocolSpy()

    Container.shared.getLegalRepresentantVerificationQRCodeUseCase.register { self.getLegalRepresentantVerificationQRCodeUseCase }

    viewModel = LegalRepresentantQRCodeViewModel(router: router, caseId: mockCaseId)
  }

  func initialState() {
    XCTAssertTrue(viewModel.isShareQRCodeDisabled)
    XCTAssertEqual(viewModel.state, .loading)
  }

  func testFinish() {
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

  // MARK: Private

  private let mockCaseId = "caseId"
  private var router: MockEIDRequestRouter!
  private var viewModel: LegalRepresentantQRCodeViewModel!
  private var getLegalRepresentantVerificationQRCodeUseCase: GetLegalRepresentantVerificationQRCodeUseCaseProtocolSpy!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
