import Factory
import XCTest
@testable import BITEIDRequest
@testable import BITQRCode
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

final class GetWalletPairingQRCodeUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    registerMocks()
    useCase = FetchWalletPairingOfferUseCase()
    setupSuccessState()
  }

  func testExecute_happyPath_parameters() async throws {
    let result = try await useCase.execute(for: mockCaseId)

    XCTAssertEqual(result.qrCodeImageData, mockQRCodeGeneratorData)
    XCTAssertEqual(repository.pairWalletCaseIdReceivedCaseId, mockCaseId)
    XCTAssertEqual(qrCodeGenerator.generateFromCorrectionLevelScaleReceivedArguments?.input, mockWalletPairingResponse.credentialOfferLink.absoluteString)
  }

  func testExecute_happyPath_callCount() async throws {
    _ = try await useCase.execute(for: mockCaseId)

    XCTAssertEqual(repository.pairWalletCaseIdCallsCount, 1)
    XCTAssertEqual(qrCodeGenerator.generateFromCorrectionLevelScaleCallsCount, 1)
  }

  func testExecute_repositoryFailure_expectError() async throws {
    repository.pairWalletCaseIdThrowableError = TestingError.error

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
      XCTAssertEqual(error as? FetchWalletPairingOfferUseCaseError, .QRCodeGenerationFailed)
    }
  }

  // MARK: Private

  private let mockCaseId = "caseId"
  private let mockQRCodeGeneratorData = "qr_code_data".data(using: .utf8)!
  private let mockWalletPairingResponse = WalletPairingResponse.Mock.sample

  private var useCase: FetchWalletPairingOfferUseCase!

  private var qrCodeGenerator: QRCodeGeneratorProtocolSpy!
  private var repository: EIDRequestRepositoryProtocolSpy!

  private func setupSuccessState() {
    repository.pairWalletCaseIdReturnValue = mockWalletPairingResponse
    qrCodeGenerator.generateFromCorrectionLevelScaleReturnValue = mockQRCodeGeneratorData
  }

  private func registerMocks() {
    repository = EIDRequestRepositoryProtocolSpy()
    qrCodeGenerator = QRCodeGeneratorProtocolSpy()

    Container.shared.eIDRequestRepository.register { self.repository }
    Container.shared.qrCodeGenerator.register { self.qrCodeGenerator }
  }

}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
