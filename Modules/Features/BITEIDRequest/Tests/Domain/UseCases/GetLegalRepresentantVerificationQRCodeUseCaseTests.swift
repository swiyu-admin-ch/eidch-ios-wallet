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
    let result = try await useCase.execute(for: caseIdMock)

    XCTAssertEqual(result.imageData, qrCodeMock)
    XCTAssertEqual(result.shareLink, verifierLinkMock)
    XCTAssertEqual(verificationService.getQRCodeForReceivedCaseId, caseIdMock)
    XCTAssertEqual(verificationService.getQRCodeForCallsCount, 1)
  }

  func testExecute_serviceFailure_expectError() async throws {
    verificationService.getQRCodeForThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: caseIdMock)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let caseIdMock = "caseId"
  private let qrCodeMock = "qrCodeMock".data(using: .utf8)!
  private let requestURLMock = URL(string: "https://example.com")!
  private let verifierLinkMock = URL(string: "https://example.com")!

  private var useCase: GetLegalRepresentantVerificationQRCodeUseCase!

  private var verificationService: LegalRepresentantVerificationServiceProtocolSpy!

  private func setupSuccessState() {
    verificationService.getQRCodeForReturnValue = (qrCodeMock, verifierLinkMock)
  }

  private func registerMocks() {
    verificationService = LegalRepresentantVerificationServiceProtocolSpy()

    Container.shared.legalRepresentantVerificationService.register { self.verificationService }
  }

}
