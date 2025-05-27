import BITQRCode
import Factory
import Foundation
import Spyable

// MARK: - GetLegalRepresentantVerificationQRCodeUseCaseProtocol

@Spyable
protocol GetLegalRepresentantVerificationQRCodeUseCaseProtocol {
  func execute(for caseId: String) async throws -> (imageData: Data, shareLink: URL)
}

// MARK: - GetLegalRepresentantVerificationQRCodeUseCase

struct GetLegalRepresentantVerificationQRCodeUseCase: GetLegalRepresentantVerificationQRCodeUseCaseProtocol {
  func execute(for caseId: String) async throws -> (imageData: Data, shareLink: URL) {
    let legalRepresentantVerification = try await eIDRequestRepository.fetchLegalRepresentantVerification(for: caseId)

    guard let qrCodeData = qrCodeGenerator.generate(from: legalRepresentantVerification.requestUrl.absoluteString) else {
      throw GetLegalRepresentantVerificationQRCodeUseCaseError.failedToGenerateQRCode
    }

    return (qrCodeData, legalRepresentantVerification.verifierLink)
  }

  @Injected(\.qrCodeGenerator) private var qrCodeGenerator: QRCodeGeneratorProtocol
  @Injected(\.eIDRequestRepository) private var eIDRequestRepository: EIDRequestRepositoryProtocol
}

// MARK: - GetLegalRepresentantVerificationQRCodeUseCaseError

enum GetLegalRepresentantVerificationQRCodeUseCaseError: Error {
  case failedToGenerateQRCode
}
