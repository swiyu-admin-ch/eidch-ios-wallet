import Factory
import FactoryTesting
import Testing
@testable import BITEIDRequest
@testable import BITTestingCore

@Suite(.container)
struct CancelRequestCaseUseCaseTests {

  // MARK: Lifecycle

  init() {
    let sidRepository = SIDRepositoryProtocolSpy()
    self.sidRepository = sidRepository

    Container.shared.sidRepository.register { sidRepository }

    useCase = CancelRequestCaseUseCase()
  }

  // MARK: Internal

  @Test
  func callAsFunction_success() async throws {
    try await useCase(for: mockCaseId)

    #expect(sidRepository.abortRequestCaseForCallsCount == 1)
    #expect(sidRepository.abortRequestCaseForReceivedCaseId == mockCaseId)
  }

  @Test
  func callAsFunction_abortRequestCaseFails_throws() async {
    sidRepository.abortRequestCaseForThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await useCase(for: mockCaseId)
    }
  }

  // MARK: Private

  private let useCase: CancelRequestCaseUseCase

  private let mockCaseId = "caseId"
  private let sidRepository: SIDRepositoryProtocolSpy
}
