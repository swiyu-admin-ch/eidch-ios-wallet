import BITAppAttestation
import BITNetworking
import Factory
import Foundation
import Spyable


@Spyable
protocol EIDRequestRepositoryProtocol {
  func submitRequest(with body: EIDRequestPayload) async throws -> EIDRequestResponse
  func fetchRequestStatus(for caseId: String) async throws -> EIDRequestStatus
  func fetchLegalRepresentantVerification(for requestCaseId: String) async throws -> LegalRepresentantVerificationResponse
  func validateAttestations(_ requestBody: ValidateAttestationsRequestBody) async throws
  func startOnlineSession(caseId: String) async throws
}


struct EIDRequestRepository: EIDRequestRepositoryProtocol {

  // MARK: Internal

  func submitRequest(with body: EIDRequestPayload) async throws -> EIDRequestResponse {
    let clientAttestationPlugin = try await generateClientAttestationPlugin(for: body)

    return try await networkService.request(EIDRequestEndpoint.submit(body), decoder: eIDRequestResponseDecoder, plugins: [clientAttestationPlugin])
  }

  func fetchRequestStatus(for caseId: String) async throws -> EIDRequestStatus {
    let clientAttestation = try await clientAttestationRepository.get()

    return try await networkService.request(EIDRequestEndpoint.getStatus(caseId: caseId), plugins: [ClientAttestationPlugin(clientAttestation: clientAttestation.rawJWS)])
  }

  func fetchLegalRepresentantVerification(for requestCaseId: String) async throws -> LegalRepresentantVerificationResponse {
    let clientAttestation = try await clientAttestationRepository.get()

    return try await networkService.request(
      EIDRequestEndpoint.legalRepresentantVerification(caseId: requestCaseId),
      plugins: [ClientAttestationPlugin(
        clientAttestation: clientAttestation.rawJWS
      )])
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

  func startOnlineSession(caseId: String) async throws {
    let clientAttestationPlugin = try await generateClientAttestationPlugin(for: EIDRequestEmptyBody())

    try await networkService.request(EIDRequestEndpoint.startOnlineSession(caseId: caseId), plugins: [clientAttestationPlugin])
  }

  // MARK: Private

  @Injected(\.sidUrl) private var sidUrl: URL
  @Injected(\NetworkContainer.service) private var networkService: NetworkService
  @Injected(\.eIDRequestResponseDecoder) private var eIDRequestResponseDecoder: JSONDecoder
  @Injected(\.proofOfPossessionGenerator) private var proofOfPossessionGenerator: ProofOfPossessionGeneratorProtocol
  @Injected(\.clientAttestationRepository) private var clientAttestationRepository: ClientAttestationRepositoryProtocol

  private func parseError(_ error: NetworkError) throws -> Swift.Error {
    let validationErrorResponse = try JSONDecoder().decode(ValidateAttestationsErrorResponse.self, from: error.response?.data ?? Data())

    guard let validationError = validationErrorResponse.errors.first, let code = validationError.code else {
      return error
    }

    return switch code {
    case .invalidClientAttestation: Error.invalidClientAttestation
    case .invalidKeyAttestation: Error.invalidKeyAttestation
    case .insufficientKeyStorageResistance: Error.insufficientKeyStorageResistance
    case .noResourcesFounded: Error.unknownError
    }
  }

  private func generateClientAttestationPlugin(for body: Encodable) async throws -> ClientAttestationPlugin {
    let (clientAttestation, proofOfPossession) = try await proofOfPossessionGenerator.generate(
      for: body,
      audience: sidUrl.absoluteString,
      challengeEndpoint: URL(target: EIDRequestEndpoint.challenge))

    return ClientAttestationPlugin(clientAttestation: clientAttestation.rawJWS, proofOfPossession: proofOfPossession.rawJWS)
  }
}


extension EIDRequestRepository {
  enum Error: Swift.Error {
    case invalidClientAttestation
    case invalidKeyAttestation
    case insufficientKeyStorageResistance
    case unknownError
  }
}


extension EIDRequestRepository {
  /// Empty codable struct to generate a Proof of Possesion without body
  fileprivate struct EIDRequestEmptyBody: Codable { }
}
