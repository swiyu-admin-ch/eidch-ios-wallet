import Factory
import Moya
import Spyable
import XCTest
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_cast

final class SubmitEIDRequestFileUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()

    useCase = SubmitEIDRequestFileUseCase()
  }

  func testExecute_validParameters_callsRepository() async throws {
    try await useCase.execute(caseId: mockCaseId, file: mockFile, authJwt: mockAuthJwt, mockProgressBlock)

    XCTAssertEqual(eidRequestRepository.submitFileCaseIdAuthJwtCallsCount, 1)
  }

  func testExecute_validParameters_passesCorrectArguments() async throws {
    try await useCase.execute(caseId: mockCaseId, file: mockFile, authJwt: mockAuthJwt, mockProgressBlock)

    XCTAssertEqual(eidRequestRepository.submitFileCaseIdAuthJwtReceivedArguments?.caseId, mockCaseId)
    XCTAssertEqual(eidRequestRepository.submitFileCaseIdAuthJwtReceivedArguments?.file, mockFile)
    XCTAssertEqual(eidRequestRepository.submitFileCaseIdAuthJwtReceivedArguments?.authJwt, mockAuthJwt)
    XCTAssertNotNil(eidRequestRepository.submitFileCaseIdAuthJwtReceivedArguments?.progress)
  }

  func testExecute_withoutProgressBlock_passesNil() async throws {
    try await useCase.execute(caseId: mockCaseId, file: mockFile, authJwt: mockAuthJwt, nil)

    XCTAssertNil(eidRequestRepository.submitFileCaseIdAuthJwtReceivedArguments?.progress)
  }

  func testExecute_repositoryThrowsError_propagatesError() async throws {
    eidRequestRepository.submitFileCaseIdAuthJwtThrowableError = TestingError.error

    do {
      try await useCase.execute(caseId: mockCaseId, file: mockFile, authJwt: mockAuthJwt, mockProgressBlock)
      XCTFail("Expected a TestingError.error instead")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_multipleCalls_callsRepositoryEachTime() async throws {
    try await useCase.execute(caseId: mockCaseId, file: mockFile, authJwt: mockAuthJwt, mockProgressBlock)
    try await useCase.execute(caseId: "another_case_id", file: mockFile, authJwt: "another_jwt", nil)

    XCTAssertEqual(eidRequestRepository.submitFileCaseIdAuthJwtCallsCount, 2)
  }

  // MARK: Private

  private var eidRequestRepository: EIDRequestRepositoryProtocolSpy!
  private var useCase: SubmitEIDRequestFileUseCase!

  private let mockCaseId = "mock_case_id"
  private let mockAuthJwt = "mock_auth_jwt"
  private let mockFile = EIDRequestCaseFile.Mock.sample
  private let mockProgressBlock: ProgressBlock = { _ in }

  private func registerMocks() {
    eidRequestRepository = EIDRequestRepositoryProtocolSpy()

    Container.shared.eIDRequestRepository.register { self.eidRequestRepository }
  }
}
