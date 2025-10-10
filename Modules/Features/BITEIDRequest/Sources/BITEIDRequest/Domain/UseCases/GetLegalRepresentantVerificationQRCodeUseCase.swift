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
    try await legalRepresentantVerificationService.getQRCode(for: caseId)
  }

  @Injected(\.legalRepresentantVerificationService) private var legalRepresentantVerificationService: LegalRepresentantVerificationServiceProtocol
}
