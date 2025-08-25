import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITQRCode
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

final class GetLegalRepresentantVerificationQRCodeUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    registerMocks()
    useCase = GetLegalRepresentantVerificationQRCodeUseCase()
    setupSuccessState()
  }

  func testExecute_happyPath_parameters() async throws {
    let result = try await useCase.execute(for: mockCaseId)

    XCTAssertEqual(result.shareLink, mockLegalRepresentantVerification.verifierLink)
    XCTAssertEqual(repository.fetchLegalRepresentantVerificationForReceivedRequestCaseId, mockCaseId)
    XCTAssertEqual(qrCodeGenerator.generateFromCorrectionLevelScaleReceivedArguments?.input, mockLegalRepresentantVerification.requestUrl.absoluteString)
  }

  func testExecute_happyPath_callCount() async throws {
    let result = try await useCase.execute(for: mockCaseId)

    XCTAssertEqual(result.shareLink, mockLegalRepresentantVerification.verifierLink)
    XCTAssertEqual(repository.fetchLegalRepresentantVerificationForCallsCount, 1)
    XCTAssertEqual(qrCodeGenerator.generateFromCorrectionLevelScaleCallsCount, 1)
  }

  func testExecute_repositoryFailure_expectError() async throws {
    repository.fetchLegalRepresentantVerificationForThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: mockCaseId)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_qrCodeGenerationReturnsNil_expectError() async throws {
    qrCodeGenerator.generateFromCorrectionLevelScaleReturnValue = nil

    do {
      _ = try await useCase.execute(for: mockCaseId)
    } catch {
      XCTAssertEqual(error as? GetLegalRepresentantVerificationQRCodeUseCaseError, .failedToGenerateQRCode)
    }
  }

  // MARK: Private

  private let mockCaseId = "caseId"
  private let mockLegalRepresentantVerification = LegalRepresentantVerificationResponse.Mock.sample

  private var useCase: GetLegalRepresentantVerificationQRCodeUseCase!

  private var qrCodeGenerator: QRCodeGeneratorProtocolSpy!
  private var repository: EIDRequestRepositoryProtocolSpy!

  private func setupSuccessState() {
    repository.fetchLegalRepresentantVerificationForReturnValue = mockLegalRepresentantVerification
    qrCodeGenerator.generateFromCorrectionLevelScaleReturnValue = Data()
  }

  private func registerMocks() {
    repository = EIDRequestRepositoryProtocolSpy()
    qrCodeGenerator = QRCodeGeneratorProtocolSpy()

    Container.shared.eIDRequestRepository.register { self.repository }
    Container.shared.qrCodeGenerator.register { self.qrCodeGenerator }
  }

}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
