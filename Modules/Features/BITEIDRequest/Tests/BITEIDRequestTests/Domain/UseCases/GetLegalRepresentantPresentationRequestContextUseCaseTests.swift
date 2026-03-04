import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITInvitation
@testable import BITPresentation
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

final class GetLegalRepresentantPresentationRequestContextUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    Container.shared.reset()
    registerMocks()
    useCase = GetLegalRepresentantPresentationRequestContextUseCase()
    setupSuccessState()
  }

  func testExecute_success() async throws {
    let context = try await useCase.execute(for: caseIdMock)

    XCTAssertEqual(context.requestObject, contextMock.requestObject)
    XCTAssertEqual(verificationService.getURLForReceivedCaseId, caseIdMock)
    XCTAssertEqual(verificationService.getURLForCallsCount, 1)
    XCTAssertEqual(fetchPresentationRequestUseCase.executeUrlReceivedUrl, verifierLinkMock)
    XCTAssertEqual(fetchPresentationRequestUseCase.executeUrlCallsCount, 1)
  }

  func testExecute_serviceFailure_expectError() async throws {
    verificationService.getURLForThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: caseIdMock)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_requestUseCaseFailure_expectError() async throws {
    fetchPresentationRequestUseCase.executeUrlThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: caseIdMock)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let caseIdMock = "caseId"
  private let contextMock = PresentationRequestContext.Mock.vcSdJwtSample
  private let verifierLinkMock = URL(string: "https://example.com")!

  private var useCase: GetLegalRepresentantPresentationRequestContextUseCase!

  private var verificationService: LegalRepresentantVerificationServiceProtocolSpy!
  private var fetchPresentationRequestUseCase: FetchPresentationRequestUseCaseProtocolSpy!

  private func setupSuccessState() {
    fetchPresentationRequestUseCase.executeUrlReturnValue = contextMock
    verificationService.getURLForReturnValue = verifierLinkMock
  }

  private func registerMocks() {
    verificationService = LegalRepresentantVerificationServiceProtocolSpy()
    fetchPresentationRequestUseCase = FetchPresentationRequestUseCaseProtocolSpy()

    Container.shared.legalRepresentantVerificationService.register { self.verificationService }
    Container.shared.fetchPresentationRequestUseCase.register { self.fetchPresentationRequestUseCase }
  }

}
