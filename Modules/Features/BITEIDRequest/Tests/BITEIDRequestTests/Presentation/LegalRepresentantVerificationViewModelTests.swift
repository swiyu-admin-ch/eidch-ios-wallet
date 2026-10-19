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

  override func setUp() async throws {
    try await super.setUp()
    Container.shared.reset()
    registerMocks()

    viewModel = LegalRepresentantVerificationViewModel(caseId: mockCaseId)
  }

  override func tearDown() async throws {
    Container.shared.reset()
    try await super.tearDown()
  }

  func testStartVerification_success_validRouteCalled() async {
    let context = PresentationRequestContext.Mock.vcSdJwtSample
    getLegalRepresentantPresentationRequestContextUseCaseSpy.executeForReturnValue = context

    await viewModel.startVerification()

    if case .external(.presentation(let destinationContext)) = viewModel.destination {
      XCTAssertEqual(destinationContext.requestObject, context.requestObject)
    } else {
      XCTFail("Expected destination: .external(.presentation)")
    }
  }

  func testStartVerification_notRequiredError_constentStateRouteCalled() async {
    getLegalRepresentantPresentationRequestContextUseCaseSpy.executeForThrowableError = SIDRepository.Error.legalRepresentantNotRequired
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
    let getLegalRepresentantPresentationRequestContextUseCaseSpy = GetLegalRepresentantPresentationRequestContextUseCaseProtocolSpy()
    self.getLegalRepresentantPresentationRequestContextUseCaseSpy = getLegalRepresentantPresentationRequestContextUseCaseSpy
    let updateEIDRequestCaseStatusUseCaseSpy = UpdateEIDRequestCaseStatusUseCaseProtocolSpy()
    self.updateEIDRequestCaseStatusUseCaseSpy = updateEIDRequestCaseStatusUseCaseSpy

    Container.shared.getLegalRepresentantPresentationRequestContextUseCase.register { @MainActor in getLegalRepresentantPresentationRequestContextUseCaseSpy }
    Container.shared.updateEIDRequestCaseStatusUseCase.register { @MainActor in updateEIDRequestCaseStatusUseCaseSpy }
    Container.shared.eidRequestFlowCoordinator.register { @MainActor in EIDRequestFlowCoordinatorProtocolSpy() }
  }

}
