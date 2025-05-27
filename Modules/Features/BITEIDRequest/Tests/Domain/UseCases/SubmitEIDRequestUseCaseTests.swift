// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import Spyable
import XCTest
@testable import BITEIDRequest
@testable import BITTestingCore

final class SubmitEIDRequestUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    repository = EIDRequestRepositoryProtocolSpy()
    localRepository = LocalEIDRequestRepositoryProtocolSpy()
    legalRepresentantRepository = LegalRepresentantRepositoryProcotolSpy()
    legalRepresentantRepository.getReturnValue = false

    Container.shared.eIDRequestRepository.register { self.repository }
    Container.shared.localEIDRequestRepository.register { self.localRepository }
    Container.shared.legalRepresentantRepository.register { self.legalRepresentantRepository }

    useCase = SubmitEIDRequestUseCase()
  }

  func testExecute_happyPath() async throws {
    repository.submitRequestWithReturnValue = mockEIDRequestResponse
    repository.fetchRequestStatusForReturnValue = mockEIDRequestStatus
    localRepository.createEIDRequestCaseReturnValue = mockEIDRequestCase

    let result = try await useCase.execute(mockPayload.mrz)

    XCTAssertEqual(repository.submitRequestWithReceivedPayload, mockPayload)
    XCTAssertEqual(repository.fetchRequestStatusForReceivedCaseId, mockEIDRequestResponse.caseId)
    XCTAssertEqual(localRepository.createEIDRequestCaseReceivedEIDRequestCase?.id, mockEIDRequestResponse.caseId)
    XCTAssertNotNil(localRepository.createEIDRequestCaseReceivedEIDRequestCase?.state)
    XCTAssertEqual(result.requestCase, mockEIDRequestCase)
    XCTAssertEqual(result.status, mockEIDRequestStatus)
  }

  func testExecute_submitRequest_throwsError() async throws {
    repository.submitRequestWithThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(mockPayload.mrz)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_fetchRequestStatusThrowsError_returnsNil() async throws {
    repository.submitRequestWithReturnValue = mockEIDRequestResponse
    repository.fetchRequestStatusForThrowableError = TestingError.error

    let result = try await useCase.execute(mockPayload.mrz)

    XCTAssertNil(result.status)
    XCTAssertEqual(result.requestCase.id, mockEIDRequestResponse.caseId)
    XCTAssertEqual(result.requestCase.lastName, mockEIDRequestResponse.lastName)
    XCTAssertEqual(result.requestCase.firstName, mockEIDRequestResponse.firstName)
    XCTAssertEqual(result.requestCase.documentNumber, mockEIDRequestResponse.identityNumber)
  }

  func testExecute_saveRequestCase_throwsError() async throws {
    repository.submitRequestWithReturnValue = mockEIDRequestResponse
    repository.fetchRequestStatusForReturnValue = mockEIDRequestStatus
    localRepository.createEIDRequestCaseThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(mockPayload.mrz)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let mockPayload = MRZData.Mock.array.first!.payload
  private let mockEIDRequestResponse: EIDRequestResponse = .Mock.sample
  private let mockEIDRequestStatus: EIDRequestStatus = .Mock.inQueueSample
  private let mockEIDRequestCase: EIDRequestCase = .Mock.sampleWithoutState
  private let mockEIDRequestCaseWithoutState: EIDRequestCase = .Mock.sampleWithoutState
  private var repository: EIDRequestRepositoryProtocolSpy!
  private var useCase: SubmitEIDRequestUseCase!
  private var localRepository: LocalEIDRequestRepositoryProtocolSpy!
  private var legalRepresentantRepository: LegalRepresentantRepositoryProcotolSpy!

}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
