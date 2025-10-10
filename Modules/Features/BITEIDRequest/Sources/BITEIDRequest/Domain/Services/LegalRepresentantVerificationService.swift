import BITQRCode
import Factory
import Foundation
import Spyable

// MARK: - LegalRepresentantVerificationServiceProtocol

@Spyable
protocol LegalRepresentantVerificationServiceProtocol {
  func getURL(for caseId: String) async throws -> URL
  func getQRCode(for caseId: String) async throws -> (imageData: Data, shareLink: URL)
}

// MARK: - LegalRepresentantVerificationService

struct LegalRepresentantVerificationService: LegalRepresentantVerificationServiceProtocol {

  // MARK: Internal

  func getURL(for caseId: String) async throws -> URL {
    let verification = try await eIDRequestRepository.fetchLegalRepresentantVerification(for: caseId)
    return verification.requestUrl
  }

  func getQRCode(for caseId: String) async throws -> (imageData: Data, shareLink: URL) {
    let verification = try await eIDRequestRepository.fetchLegalRepresentantVerification(for: caseId)

    guard let qrCodeData = qrCodeGenerator.generate(from: verification.requestUrl.absoluteString) else {
      throw LegalRepresentantVerificationServiceError.failedToGenerateQRCode
    }

    return (qrCodeData, verification.verifierLink)
  }

  // MARK: Private

  @Injected(\.qrCodeGenerator) private var qrCodeGenerator: QRCodeGeneratorProtocol
  @Injected(\.eIDRequestRepository) private var eIDRequestRepository: EIDRequestRepositoryProtocol
}

// MARK: - LegalRepresentantVerificationServiceError

enum LegalRepresentantVerificationServiceError: Error {
  case failedToGenerateQRCode
}
