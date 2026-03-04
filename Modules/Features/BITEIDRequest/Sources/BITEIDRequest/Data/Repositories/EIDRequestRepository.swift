import BITAppAttestation
import BITEIDRequestShared
import BITNetworking
import Factory
import Foundation
import Moya
import Spyable


@Spyable
protocol EIDRequestRepositoryProtocol {
  func apply(with body: EIDRequestPayload) async throws -> EIDRequestResponse
  func fetchRequestStatus(for caseId: String) async throws -> EIDRequestStatus
  func fetchLegalRepresentantVerification(for requestCaseId: String) async throws -> LegalRepresentantVerificationResponse
  func validateAttestations(_ requestBody: ValidateAttestationsRequestBody) async throws
  func startOnlineSession(caseId: String) async throws
  func pairWallet(caseId: String) async throws -> WalletPairingResponse
  func startAutoVerification(caseId: String, autoVerificationType: AutoVerificationType, isNFCAvailable: Bool) async throws -> AutoVerificationResponse
  func submitFile(_ file: EIDRequestCaseFile, caseId: String, authJwt: String, _ progress: ProgressBlock?) async throws
  func getPairingState(caseId: String, pairingId: String) async throws -> WalletPairingState
  func submitRequest(caseId: String, authJwt: String) async throws
}


struct EIDRequestRepository: EIDRequestRepositoryProtocol {

  // MARK: Internal

  func apply(with body: EIDRequestPayload) async throws -> EIDRequestResponse {
    let clientAttestationPlugin = try await generateClientAttestationPlugin(for: body)

    return try await networkService.request(EIDRequestEndpoint.apply(body), decoder: eIDRequestResponseDecoder, plugins: [clientAttestationPlugin])
  }

  func fetchRequestStatus(for caseId: String) async throws -> EIDRequestStatus {
    let clientAttestation = try await clientAttestationRepository.get()

    return try await networkService.request(EIDRequestEndpoint.getStatus(caseId: caseId), plugins: [ClientAttestationPlugin(clientAttestation: clientAttestation.rawJWS)])
  }

  func fetchLegalRepresentantVerification(for requestCaseId: String) async throws -> LegalRepresentantVerificationResponse {
    let clientAttestation = try await clientAttestationRepository.get()

    do {
      return try await networkService.request(
        EIDRequestEndpoint.legalRepresentantVerification(caseId: requestCaseId),
        plugins: [ClientAttestationPlugin(
          clientAttestation: clientAttestation.rawJWS)])
    } catch let error as NetworkError where error.status == .badRequest {
      throw try parseError(error)
    } catch {
      throw Error.unknownError
    }
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

    do {
      try await networkService.request(EIDRequestEndpoint.startOnlineSession(caseId: caseId), plugins: [clientAttestationPlugin])
    } catch let error as NetworkError {
      throw try parseError(error)
    }
  }

  func pairWallet(caseId: String) async throws -> WalletPairingResponse {
    let clientAttestationPlugin = try await generateClientAttestationPlugin(for: EIDRequestEmptyBody())

    return try await networkService.request(EIDRequestEndpoint.pairWallet(caseId: caseId), plugins: [clientAttestationPlugin])
  }

  func startAutoVerification(caseId: String, autoVerificationType: AutoVerificationType, isNFCAvailable: Bool) async throws -> AutoVerificationResponse {
    let clientAttestationPlugin = try await generateClientAttestationPlugin(for: EIDRequestEmptyBody())

    return try await networkService.request(EIDRequestEndpoint.startAutoVerification(caseId: caseId, autoVerificationType: autoVerificationType, isNFCAvailable: isNFCAvailable), plugins: [clientAttestationPlugin])
  }

  func submitFile(_ file: EIDRequestCaseFile, caseId: String, authJwt: String, _ progress: ProgressBlock?) async throws {
    let authPlugin = AccessTokenPlugin(tokenClosure: { _ in authJwt })
    try await networkService.request(EIDRequestEndpoint.submitFile(caseId: caseId, file: file), plugins: [authPlugin], progress)
  }

  func getPairingState(caseId: String, pairingId: String) async throws -> WalletPairingState {
    let clientAttestationPlugin = try await generateClientAttestationPlugin(for: EIDRequestEmptyBody())
    let response: WalletPairingStateResponse = try await networkService.request(EIDRequestEndpoint.pairingState(caseId: caseId, pairingId: pairingId), plugins: [clientAttestationPlugin])
    return response.state
  }

  func submitRequest(caseId: String, authJwt: String) async throws {
    let authPlugin = AccessTokenPlugin(tokenClosure: { _ in authJwt })
    try await networkService.request(EIDRequestEndpoint.submit(caseId: caseId), plugins: [authPlugin])
  }

  // MARK: Private

  @Injected(\.sidBaseUrl) private var sidBaseUrl: URL
  @Injected(\NetworkContainer.service) private var networkService: NetworkService
  @Injected(\.eIDRequestResponseDecoder) private var eIDRequestResponseDecoder: JSONDecoder
  @Injected(\.proofOfPossessionGenerator) private var proofOfPossessionGenerator: ProofOfPossessionGeneratorProtocol
  @Injected(\.clientAttestationRepository) private var clientAttestationRepository: ClientAttestationRepositoryProtocol

  private func parseError(_ error: NetworkError) throws -> Swift.Error {
    let errorResponse = try JSONDecoder().decode(EIDRequestErrorResponse.self, from: error.response?.data ?? Data())

    guard let firstError = errorResponse.errors.first, let code = firstError.code else {
      return error
    }

    return switch code {
    case .invalidClientAttestation: Error.invalidClientAttestation
    case .invalidKeyAttestation: Error.invalidKeyAttestation
    case .insufficientKeyStorageResistance: Error.insufficientKeyStorageResistance
    case .invalidState: Error.invalidState
    case .notFound: Error.unknownError
    case .legalRepresentantNotRequired: Error.legalRepresentantNotRequired
    }
  }

  private func generateClientAttestationPlugin(for body: Encodable) async throws -> ClientAttestationPlugin {
    let (clientAttestation, proofOfPossession) = try await proofOfPossessionGenerator.generate(
      for: body,
      audience: sidBaseUrl.absoluteString,
      challengeEndpoint: URL(target: EIDRequestEndpoint.challenge))

    return ClientAttestationPlugin(clientAttestation: clientAttestation.rawJWS, proofOfPossession: proofOfPossession.rawJWS)
  }
}


extension EIDRequestRepository {
  enum Error: Swift.Error {
    case invalidClientAttestation
    case invalidKeyAttestation
    case insufficientKeyStorageResistance
    case legalRepresentantNotRequired
    case unknownError
    case invalidState
  }
}


extension EIDRequestRepository {
  /// Empty codable struct to generate a Proof of Possesion without body
  fileprivate struct EIDRequestEmptyBody: Codable { }
}
