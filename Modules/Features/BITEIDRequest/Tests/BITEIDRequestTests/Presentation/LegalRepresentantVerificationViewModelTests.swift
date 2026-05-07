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

    viewModel = LegalRepresentantVerificationViewModel(caseId: mockCaseId)
  }

  func testStartVerification_success_validRouteCalled() async {
    let context = PresentationRequestContext.Mock.vcSdJwtSampleWithoutInputDescriptors
    getLegalRepresentantPresentationRequestContextUseCaseSpy.executeForReturnValue = context

    await viewModel.startVerification()

    if case .external(.presentation(let destinationContext)) = viewModel.destination {
      XCTAssertEqual(destinationContext.requestObject, context.requestObject)
    } else {
      XCTFail("Expected destination: .external(.presentation)")
    }
  }

  func testStartVerification_notRequiredError_constentStateRouteCalled() async {
    getLegalRepresentantPresentationRequestContextUseCaseSpy.executeForThrowableError = EIDRequestRepository.Error.legalRepresentantNotRequired
    let mockRequestCase = EIDRequestCase.Mock.sampleInQueue
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

  private var viewModel: LegalRepresentantVerificationViewModel!
  private var getLegalRepresentantPresentationRequestContextUseCaseSpy: GetLegalRepresentantPresentationRequestContextUseCaseProtocolSpy!
  private var updateEIDRequestCaseStatusUseCaseSpy: UpdateEIDRequestCaseStatusUseCaseProtocolSpy!

  private func registerMocks() {
    getLegalRepresentantPresentationRequestContextUseCaseSpy = GetLegalRepresentantPresentationRequestContextUseCaseProtocolSpy()
    updateEIDRequestCaseStatusUseCaseSpy = UpdateEIDRequestCaseStatusUseCaseProtocolSpy()

    Container.shared.getLegalRepresentantPresentationRequestContextUseCase.register { @MainActor in self.getLegalRepresentantPresentationRequestContextUseCaseSpy }
    Container.shared.updateEIDRequestCaseStatusUseCase.register { @MainActor in self.updateEIDRequestCaseStatusUseCaseSpy }
  }

}
