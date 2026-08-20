import BITInvitation
import BITPresentation
import Factory
import Foundation
import Spyable

// MARK: - GetLegalRepresentantPresentationRequestContextUseCaseProtocol

@Spyable
protocol GetLegalRepresentantPresentationRequestContextUseCaseProtocol {
  func execute(for caseId: String) async throws -> PresentationRequestContext
}

// MARK: - GetLegalRepresentantPresentationRequestContextUseCase

struct GetLegalRepresentantPresentationRequestContextUseCase: GetLegalRepresentantPresentationRequestContextUseCaseProtocol {
  func execute(for caseId: String) async throws -> PresentationRequestContext {
    let url = try await legalRepresentantVerificationService.getURL(for: caseId)
    return try await fetchPresentationRequestUseCase(url: url)
  }

  @Injected(\.legalRepresentantVerificationService) private var legalRepresentantVerificationService
  @Injected(\.fetchPresentationRequestUseCase) private var fetchPresentationRequestUseCase
}
