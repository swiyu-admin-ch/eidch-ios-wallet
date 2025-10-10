import Factory
import Spyable
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_cast

final class GetEIDRequestCaseFilesUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()

    useCase = GetEIDRequestCaseFilesUseCase()

    success()
  }

  func testExecute_validCaseId_returnsCaseFiles() async throws {
    let result = try await useCase.execute(caseId: mockCaseId)

    XCTAssertEqual(result, mockFiles)
  }

  func testExecute_validCaseId_callsRepositoryWithCorrectCaseId() async throws {
    _ = try await useCase.execute(caseId: mockCaseId)

    XCTAssertEqual(eIDRequestCaseRepository.getAllFilesForRequestCaseIdCallsCount, 1)
    XCTAssertEqual(eIDRequestCaseRepository.getAllFilesForRequestCaseIdReceivedId, mockCaseId)
  }

  func testExecute_repositoryThrowsError_propagatesError() async throws {
    eIDRequestCaseRepository.getAllFilesForRequestCaseIdThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(caseId: mockCaseId)
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_emptyResult_returnsEmptyArray() async throws {
    eIDRequestCaseRepository.getAllFilesForRequestCaseIdReturnValue = []

    let result = try await useCase.execute(caseId: mockCaseId)

    XCTAssertTrue(result.isEmpty)
  }

  func testExecute_multipleCalls_callsRepositoryEachTime() async throws {
    _ = try await useCase.execute(caseId: mockCaseId)
    _ = try await useCase.execute(caseId: "another_case_id")

    XCTAssertEqual(eIDRequestCaseRepository.getAllFilesForRequestCaseIdCallsCount, 2)
  }

  func testExecute_differentCaseIds_passesCorrectParameters() async throws {
    let caseId1 = "case_id_1"
    let caseId2 = "case_id_2"

    _ = try await useCase.execute(caseId: caseId1)
    _ = try await useCase.execute(caseId: caseId2)

    XCTAssertEqual(eIDRequestCaseRepository.getAllFilesForRequestCaseIdReceivedInvocations.count, 2)
    XCTAssertEqual(eIDRequestCaseRepository.getAllFilesForRequestCaseIdReceivedInvocations[0], caseId1)
    XCTAssertEqual(eIDRequestCaseRepository.getAllFilesForRequestCaseIdReceivedInvocations[1], caseId2)
  }

  // MARK: Private

  private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocolSpy!
  private var useCase: GetEIDRequestCaseFilesUseCase!

  private let mockCaseId = "mock_case_id"
  private let mockFiles = EIDRequestCaseFile.Mock.sampleArray

  private func registerMocks() {
    eIDRequestCaseRepository = EIDRequestCaseRepositoryProtocolSpy()

    Container.shared.eIDRequestCaseRepository.register { self.eIDRequestCaseRepository }
  }

  private func success() {
    eIDRequestCaseRepository.getAllFilesForRequestCaseIdReturnValue = mockFiles
  }
}
