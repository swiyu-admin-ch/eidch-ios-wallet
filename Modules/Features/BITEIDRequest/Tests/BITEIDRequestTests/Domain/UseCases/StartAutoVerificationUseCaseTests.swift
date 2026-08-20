import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

final class StartAutoVerificationUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    sidRepository = SIDRepositoryProtocolSpy()
    sidRepository.startAutoVerificationCaseIdAutoVerificationTypeIsNFCAvailableReturnValue = mockAutoVerificationResponse
    Container.shared.sidRepository.register { self.sidRepository }

    useCase = StartAutoVerificationUseCase()
  }

  func testExecute_success() async throws {
    let result = try await useCase.execute(for: mockCaseId)

    XCTAssertEqual(result, mockAutoVerificationResponse)
    XCTAssertEqual(sidRepository.startAutoVerificationCaseIdAutoVerificationTypeIsNFCAvailableCallsCount, 1)
    XCTAssertEqual(sidRepository.startAutoVerificationCaseIdAutoVerificationTypeIsNFCAvailableReceivedArguments?.caseId, mockCaseId)
    XCTAssertEqual(sidRepository.startAutoVerificationCaseIdAutoVerificationTypeIsNFCAvailableReceivedArguments?.autoVerificationType, .av1)
  }

  func testExecute_failure() async throws {
    sidRepository.startAutoVerificationCaseIdAutoVerificationTypeIsNFCAvailableThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: mockCaseId)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let mockCaseId = "mockCaseId"
  private let mockAutoVerificationResponse = AutoVerificationResponse.Mock.nfcSample

  private var useCase: StartAutoVerificationUseCase!
  private var sidRepository: SIDRepositoryProtocolSpy!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
