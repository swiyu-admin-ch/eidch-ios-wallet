import BITNetworking
import Factory
import Foundation
import Spyable


@Spyable
protocol EIDRequestRepositoryProtocol {
  func submitRequest(with payload: EIDRequestPayload) async throws -> EIDRequestResponse
  func fetchRequestStatus(for caseId: String) async throws -> EIDRequestStatus
  func fetchLegalRepresentantVerification(for requestCaseId: String) async throws -> LegalRepresentantVerificationResponse
}


struct EIDRequestRepository: EIDRequestRepositoryProtocol {

  func submitRequest(with payload: EIDRequestPayload) async throws -> EIDRequestResponse {
    try await networkService.request(EIDRequestEndpoint.submit(payload: payload), decoder: eIDRequestResponseDecoder)
  }

  func fetchRequestStatus(for caseId: String) async throws -> EIDRequestStatus {
    try await networkService.request(EIDRequestEndpoint.getStatus(caseId: caseId))
  }

  func fetchLegalRepresentantVerification(for requestCaseId: String) async throws -> LegalRepresentantVerificationResponse {
    try await networkService.request(EIDRequestEndpoint.legalRepresentantVerification(caseId: requestCaseId))
  }

  @Injected(\NetworkContainer.service) private var networkService: NetworkService
  @Injected(\.eIDRequestResponseDecoder) private var eIDRequestResponseDecoder: JSONDecoder
}
