import Factory
import FactoryTesting
import Testing
@testable import BITEIDRequest
@testable import BITTestingCore

@Suite(.container)
struct ResetRequestCasePairingUseCaseTests {

  // MARK: Lifecycle

  init() {
    let requestCaseRepository = EIDRequestCaseRepositoryProtocolSpy()
    self.requestCaseRepository = requestCaseRepository

    Container.shared.eIDRequestCaseRepository.register { requestCaseRepository }

    useCase = ResetRequestCasePairingUseCase()
  }

  // MARK: Internal

  @Test
  func callAsFunction_success() async throws {
    try await useCase(for: mockCaseId)

    #expect(requestCaseRepository.deletePairingsForCallsCount == 1)
    #expect(requestCaseRepository.deletePairingsForReceivedRequestCase == mockCaseId)
  }

  @Test
  func callAsFunction_deletePairingsFails_throws() async {
    requestCaseRepository.deletePairingsForThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await useCase(for: mockCaseId)
    }
  }

  // MARK: Private

  private let useCase: ResetRequestCasePairingUseCase

  private let mockCaseId = "caseId"
  private let requestCaseRepository: EIDRequestCaseRepositoryProtocolSpy
}
