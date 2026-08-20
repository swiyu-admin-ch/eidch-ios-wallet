import Factory
import Testing
@testable import BITEIDRequest
@testable import BITTestingCore

struct DeleteEIDRequestCaseUseCaseTests {

  // MARK: Lifecycle

  init() {
    let requestCaseRepository = EIDRequestCaseRepositoryProtocolSpy()
    self.requestCaseRepository = requestCaseRepository

    Container.shared.eIDRequestCaseRepository.register { requestCaseRepository }

    useCase = DeleteEIDRequestCaseUseCase()
  }

  // MARK: Internal

  @Test
  func execute_success() async throws {
    try await useCase.execute(mockCaseId)

    #expect(requestCaseRepository.deleteCallsCount == 1)
    #expect(requestCaseRepository.deleteReceivedId == mockCaseId)
  }

  @Test
  func execute_deleteRequestCaseFails_throws() async {
    requestCaseRepository.deleteThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await useCase.execute(mockCaseId)
    }
  }

  // MARK: Private

  private let useCase: DeleteEIDRequestCaseUseCase

  private let mockCaseId = "caseId"
  private let requestCaseRepository: EIDRequestCaseRepositoryProtocolSpy
}
