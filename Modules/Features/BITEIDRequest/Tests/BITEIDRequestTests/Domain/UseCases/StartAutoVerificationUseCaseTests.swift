import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

final class StartAutoVerificationUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    eIDRequestRepository = EIDRequestRepositoryProtocolSpy()
    eIDRequestRepository.startAutoVerificationCaseIdAutoVerificationTypeIsNFCAvailableReturnValue = mockAutoVerificationResponse
    Container.shared.eIDRequestRepository.register { self.eIDRequestRepository }

    useCase = StartAutoVerificationUseCase()
  }

  func testExecute_success() async throws {
    let result = try await useCase.execute(for: mockCaseId)

    XCTAssertEqual(result, mockAutoVerificationResponse)
    XCTAssertEqual(eIDRequestRepository.startAutoVerificationCaseIdAutoVerificationTypeIsNFCAvailableCallsCount, 1)
    XCTAssertEqual(eIDRequestRepository.startAutoVerificationCaseIdAutoVerificationTypeIsNFCAvailableReceivedArguments?.caseId, mockCaseId)
    XCTAssertEqual(eIDRequestRepository.startAutoVerificationCaseIdAutoVerificationTypeIsNFCAvailableReceivedArguments?.autoVerificationType, .av1)
  }

  func testExecute_failure() async throws {
    eIDRequestRepository.startAutoVerificationCaseIdAutoVerificationTypeIsNFCAvailableThrowableError = TestingError.error

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
  private var eIDRequestRepository: EIDRequestRepositoryProtocolSpy!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
