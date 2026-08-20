import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITQRCode
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

final class LegalRepresentantVerificationServiceTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    Container.shared.reset()
    registerMocks()
    service = LegalRepresentantVerificationService()
    setupSuccessState()
  }

  func testGetURL_success() async throws {
    let url = try await service.getURL(for: caseIdMock)

    XCTAssertEqual(url, legalRepresentantVerificationMock.requestUrl)
    XCTAssertEqual(repositorySpy.fetchLegalRepresentantVerificationForCallsCount, 1)
    XCTAssertEqual(repositorySpy.fetchLegalRepresentantVerificationForReceivedRequestCaseId, caseIdMock)
  }

  func testGetURL_repositoryFailure_expectError() async throws {
    repositorySpy.fetchLegalRepresentantVerificationForThrowableError = TestingError.error

    do {
      _ = try await service.getURL(for: caseIdMock)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testGetQRCode_success() async throws {
    let result = try await service.getQRCode(for: caseIdMock)

    XCTAssertEqual(result.shareLink, legalRepresentantVerificationMock.verifierLink)
    XCTAssertEqual(result.imageData, qrCodeMock)

    XCTAssertEqual(repositorySpy.fetchLegalRepresentantVerificationForReceivedRequestCaseId, caseIdMock)
    XCTAssertEqual(repositorySpy.fetchLegalRepresentantVerificationForCallsCount, 1)
    XCTAssertEqual(qrCodeGeneratorSpy.generateFromCorrectionLevelScaleReceivedArguments?.input, legalRepresentantVerificationMock.requestUrl.absoluteString)
    XCTAssertEqual(qrCodeGeneratorSpy.generateFromCorrectionLevelScaleCallsCount, 1)
  }

  func testGetQRCode_repositoryFailure_expectError() async throws {
    repositorySpy.fetchLegalRepresentantVerificationForThrowableError = TestingError.error

    do {
      _ = try await service.getQRCode(for: caseIdMock)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
    XCTAssertEqual(qrCodeGeneratorSpy.generateFromCorrectionLevelScaleCallsCount, 0)
  }

  func testGetQRCode_qrCodeGenerationReturnsNil_expectError() async throws {
    qrCodeGeneratorSpy.generateFromCorrectionLevelScaleReturnValue = nil

    do {
      _ = try await service.getQRCode(for: caseIdMock)
    } catch {
      XCTAssertEqual(error as? LegalRepresentantVerificationServiceError, .failedToGenerateQRCode)
    }
  }

  // MARK: Private

  private let caseIdMock = "caseId"
  private let qrCodeMock = "qrCodeMock".data(using: .utf8)
  private let legalRepresentantVerificationMock = LegalRepresentantVerificationResponse.Mock.sample

  private var service: LegalRepresentantVerificationService!

  private var qrCodeGeneratorSpy: QRCodeGeneratorProtocolSpy!
  private var repositorySpy: SIDRepositoryProtocolSpy!

  private func setupSuccessState() {
    repositorySpy.fetchLegalRepresentantVerificationForReturnValue = legalRepresentantVerificationMock
    qrCodeGeneratorSpy.generateFromCorrectionLevelScaleReturnValue = qrCodeMock
  }

  private func registerMocks() {
    repositorySpy = SIDRepositoryProtocolSpy()
    qrCodeGeneratorSpy = QRCodeGeneratorProtocolSpy()

    Container.shared.sidRepository.register { self.repositorySpy }
    Container.shared.qrCodeGenerator.register { self.qrCodeGeneratorSpy }
  }

}
