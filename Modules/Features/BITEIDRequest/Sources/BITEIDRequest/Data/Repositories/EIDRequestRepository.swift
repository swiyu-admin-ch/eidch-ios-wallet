import BITAppAttestation
import BITNetworking
import Factory
import Foundation
import Spyable


@Spyable
protocol EIDRequestRepositoryProtocol {
  func submitRequest(_ request: ClientAttestedRequest) async throws -> EIDRequestResponse
  func fetchRequestStatus(for caseId: String) async throws -> EIDRequestStatus
  func fetchLegalRepresentantVerification(for requestCaseId: String) async throws -> LegalRepresentantVerificationResponse
  func validateAttestations(_ requestBody: ValidateAttestationsRequestBody) async throws
  func fetchChallenge() async throws -> AttestationChallenge
}


struct EIDRequestRepository: EIDRequestRepositoryProtocol {

  // MARK: Internal

  func submitRequest(_ request: ClientAttestedRequest) async throws -> EIDRequestResponse {
    try await networkService.request(EIDRequestEndpoint.submit(request: request), decoder: eIDRequestResponseDecoder)
  }

  func fetchRequestStatus(for caseId: String) async throws -> EIDRequestStatus {
    try await networkService.request(EIDRequestEndpoint.getStatus(caseId: caseId))
  }

  func fetchLegalRepresentantVerification(for requestCaseId: String) async throws -> LegalRepresentantVerificationResponse {
    try await networkService.request(EIDRequestEndpoint.legalRepresentantVerification(caseId: requestCaseId))
  }

  /// Business validation made by the mobile backend, without data integrity (nor Proof of possession).
  func validateAttestations(_ requestBody: ValidateAttestationsRequestBody) async throws {
    do {
      try await networkService.request(EIDRequestEndpoint.validateAttestations(requestBody))
    } catch let error as NetworkError where error.status == .unprocessableEntity {
      throw try parseError(error)
    } catch {
      throw Error.unknownError
    }
  }

  func fetchChallenge() async throws -> AttestationChallenge {
    let response = try await networkService.request(EIDRequestEndpoint.challenge)
    return try JSONDecoder().decode(AttestationChallenge.Response.self, from: response.data).challenge
  }

  // MARK: Private

  @Injected(\NetworkContainer.service) private var networkService: NetworkService
  @Injected(\.eIDRequestResponseDecoder) private var eIDRequestResponseDecoder: JSONDecoder

  private func parseError(_ error: NetworkError) throws -> Swift.Error {
    let validationErrorResponse = try JSONDecoder().decode(ValidateAttestationsErrorResponse.self, from: error.response?.data ?? Data())

    guard let validationError = validationErrorResponse.errors.first, let code = validationError.code else {
      return error
    }

    return switch code {
    case .invalidClientAttestation: Error.invalidClientAttestation
    case .invalidKeyAttestation: Error.invalidKeyAttestation
    case .insufficientKeyStorageResistance,
         .noResourcesFounded: Error.unknownError
    }
  }
}


extension EIDRequestRepository {
  enum Error: Swift.Error {
    case invalidClientAttestation
    case invalidKeyAttestation
    case unknownError
  }
}
