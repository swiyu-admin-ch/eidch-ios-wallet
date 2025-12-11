// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITPresentation
@testable import BITTestingCore

@MainActor
class LegalRepresentantVerificationViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.reset()
    registerMocks()

    router = MockEIDRequestRouter()

    viewModel = LegalRepresentantVerificationViewModel(router: router, caseId: mockCaseId)
  }

  func testStartVerification_success_validRouteCalled() async {
    let context = PresentationRequestContext.Mock.vcSdJwtSampleWithoutInputDescriptors
    getLegalRepresentantPresentationRequestContextUseCaseSpy.executeForReturnValue = context

    await viewModel.startVerification()

    XCTAssertEqual(router.startPresentationContext?.requestObject, context.requestObject)
  }

  func testStartVerification_notRequiredError_constentStateRouteCalled() async throws {
    getLegalRepresentantPresentationRequestContextUseCaseSpy.executeForThrowableError = EIDRequestRepository.Error.legalRepresentantNotRequired
    let mockRequestCase = EIDRequestCase.Mock.sampleInQueue
    let mockRequestCaseStateView = try RequestCaseViewState(mockRequestCase)
    updateEIDRequestCaseStatusUseCaseSpy.executeForReturnValue = mockRequestCase

    await viewModel.startVerification()

    if case .legalRepresentantConsentState = viewModel.destination {
      XCTAssert(true)
    } else {
      XCTFail("Expected destination: .legalRepresentantConsentState")
    }
  }

  func testStartVerification_useCaseError_errorRouteCalled() async {
    getLegalRepresentantPresentationRequestContextUseCaseSpy.executeForThrowableError = TestingError.error

    await viewModel.startVerification()

    if case .error = viewModel.destination {
      XCTAssert(true)
    } else {
      XCTFail("Expected destination: .error")
    }
  }

  // MARK: Private

  private let mockCaseId = "caseId"

  private var router: MockEIDRequestRouter!
  private var viewModel: LegalRepresentantVerificationViewModel!
  private var getLegalRepresentantPresentationRequestContextUseCaseSpy: GetLegalRepresentantPresentationRequestContextUseCaseProtocolSpy!
  private var updateEIDRequestCaseStatusUseCaseSpy: UpdateEIDRequestCaseStatusUseCaseProtocolSpy!

  private func registerMocks() {
    getLegalRepresentantPresentationRequestContextUseCaseSpy = GetLegalRepresentantPresentationRequestContextUseCaseProtocolSpy()
    updateEIDRequestCaseStatusUseCaseSpy = UpdateEIDRequestCaseStatusUseCaseProtocolSpy()

    Container.shared.getLegalRepresentantPresentationRequestContextUseCase.register { self.getLegalRepresentantPresentationRequestContextUseCaseSpy }
    Container.shared.updateEIDRequestCaseStatusUseCase.register { self.updateEIDRequestCaseStatusUseCaseSpy }
  }

}
