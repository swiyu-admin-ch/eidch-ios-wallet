import Factory
import FactoryTesting
import Testing
@testable import BITEIDRequest
@testable import BITTestingCore

@Suite(.container)
struct SaveWalletPairingIdUseCaseTests {

  // MARK: Lifecycle

  init() {
    let requestCaseRepository = EIDRequestCaseRepositoryProtocolSpy()
    self.requestCaseRepository = requestCaseRepository

    Container.shared.eIDRequestCaseRepository.register { requestCaseRepository }

    useCase = SaveWalletPairingIdUseCase()
  }

  // MARK: Internal

  @Test
  func callAsFunction_success() async throws {
    try await useCase(mockPairingId, forRequestCase: mockCaseId)

    #expect(requestCaseRepository.savePairingIdForRequestCaseIdCallsCount == 1)
    #expect(requestCaseRepository.savePairingIdForRequestCaseIdReceivedArguments?.id == mockCaseId)
    #expect(requestCaseRepository.savePairingIdForRequestCaseIdReceivedArguments?.pairingId == mockPairingId)
  }

  @Test
  func execute_savePairingIdFails_throws() async {
    requestCaseRepository.savePairingIdForRequestCaseIdThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await useCase(mockPairingId, forRequestCase: mockCaseId)
    }
  }

  // MARK: Private

  private let useCase: SaveWalletPairingIdUseCase

  private let mockCaseId = "caseId"
  private let mockPairingId = "pairingId"
  private let requestCaseRepository: EIDRequestCaseRepositoryProtocolSpy
}
