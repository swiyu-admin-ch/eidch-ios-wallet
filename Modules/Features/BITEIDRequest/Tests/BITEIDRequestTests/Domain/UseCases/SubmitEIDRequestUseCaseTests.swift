import Factory
import Spyable
import Testing
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

struct SubmitEIDRequestUseCaseTests {

  // MARK: Lifecycle

  init() {
    let avRepository = AVRepositoryProtocolSpy()
    self.avRepository = avRepository

    let eIDRequestCaseRepository = EIDRequestCaseRepositoryProtocolSpy()
    eIDRequestCaseRepository.getIdReturnValue = mockRequestCase
    eIDRequestCaseRepository.updateReturnValue = mockRequestCase
    self.eIDRequestCaseRepository = eIDRequestCaseRepository

    Container.shared.avRepository.register { avRepository }
    Container.shared.eIDRequestCaseRepository.register { eIDRequestCaseRepository }

    useCase = SubmitEIDRequestUseCase()
  }

  // MARK: Internal

  @Test
  func callAsFunction_withValidParameters_callsRepositorySubmitRequest() async throws {
    try await useCase(caseId: mockCaseId, authJwt: mockJwt, files: mockRequestCaseFiles)

    #expect(avRepository.submitRequestCaseIdAuthJwtFilesCalled == true)
    #expect(avRepository.submitRequestCaseIdAuthJwtFilesCallsCount == 1)
    #expect(avRepository.submitRequestCaseIdAuthJwtFilesReceivedArguments?.caseId == mockCaseId)
    #expect(avRepository.submitRequestCaseIdAuthJwtFilesReceivedArguments?.authJwt == mockJwt)
    #expect(eIDRequestCaseRepository.getIdCallsCount == 1)
    #expect(eIDRequestCaseRepository.getIdReceivedId == mockCaseId)
    #expect(eIDRequestCaseRepository.updateCallsCount == 1)
    #expect(eIDRequestCaseRepository.updateReceivedEIDRequestCase?.filesSubmitted == true)
  }

  @Test
  func callAsFunction_whenRepositoryThrowsError_propagatesError() async throws {
    avRepository.submitRequestCaseIdAuthJwtFilesThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await useCase(caseId: mockCaseId, authJwt: mockJwt, files: mockRequestCaseFiles)
      #expect(avRepository.submitRequestCaseIdAuthJwtFilesCalled == true)
    }
  }

  @Test
  func callAsFunction_whenGetRequestCaseThrowsError_doesNotThrowsError() async throws {
    eIDRequestCaseRepository.getIdThrowableError = TestingError.error

    try await useCase(caseId: mockCaseId, authJwt: mockJwt, files: mockRequestCaseFiles)

    #expect(avRepository.submitRequestCaseIdAuthJwtFilesCalled == true)
    #expect(eIDRequestCaseRepository.getIdReceivedId == mockCaseId)
    #expect(eIDRequestCaseRepository.updateCallsCount == 0)
  }

  @Test
  func callAsFunction_whenUpdateRequestCaseThrowsError_doesNotThrowsError() async throws {
    eIDRequestCaseRepository.updateThrowableError = TestingError.error

    try await useCase(caseId: mockCaseId, authJwt: mockJwt, files: mockRequestCaseFiles)

    #expect(avRepository.submitRequestCaseIdAuthJwtFilesCalled == true)
    #expect(eIDRequestCaseRepository.getIdReceivedId == mockCaseId)
    #expect(eIDRequestCaseRepository.updateReceivedEIDRequestCase?.filesSubmitted == true)
  }

  // MARK: Private

  private let mockJwt = "mockJwt"
  private let mockCaseId = "mockCaseId"
  private let mockRequestCase = EIDRequestCase.Mock.sampleAutoVerification
  private let mockRequestCaseFiles = EIDRequestCaseFile.Mock.sampleArray

  private let useCase: SubmitEIDRequestUseCase
  private let avRepository: AVRepositoryProtocolSpy
  private let eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocolSpy

}
