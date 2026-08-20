import BITAppAttestation
import BITAppAuth
import BITEIDRequestShared
import BITLocalAuthentication
import BITNetworking
import Factory
import Foundation
import Moya
import Spyable

// MARK: - SIDRepositoryProtocol

@Spyable
protocol SIDRepositoryProtocol {
  func apply(with body: EIDRequestPayload) async throws -> EIDRequestResponse
  func fetchRequestStatus(for caseId: String) async throws -> EIDRequestStatus
  func fetchLegalRepresentantVerification(for requestCaseId: String) async throws -> LegalRepresentantVerificationResponse
  func validateAttestations(_ requestBody: ValidateAttestationsRequestBody) async throws
  func startOnlineSession(caseId: String) async throws
  func pairWallet(caseId: String) async throws -> WalletPairingResponse
  func startAutoVerification(caseId: String, autoVerificationType: AutoVerificationType, isNFCAvailable: Bool) async throws -> AutoVerificationResponse
  func getPairingState(caseId: String, pairingId: String) async throws -> WalletPairingState
  func registerPushId(_ body: PushIdRegistrationBody, caseId: String) async throws
  func abortRequestCase(for caseId: String) async throws
}

// MARK: - SIDRepository

struct SIDRepository: SIDRepositoryProtocol {

  // MARK: Internal

  func apply(with body: EIDRequestPayload) async throws -> EIDRequestResponse {
    let clientAttestationPlugin = try await generateClientAttestationPlugin(for: body)

    return try await networkService.request(SIDRepositoryEndpoint.apply(body), decoder: eIDRequestResponseDecoder, plugins: [clientAttestationPlugin])
  }

  func fetchRequestStatus(for caseId: String) async throws -> EIDRequestStatus {
    let clientAttestation = try await clientAttestationRepository.get(using: userContext())

    return try await networkService.request(SIDRepositoryEndpoint.getStatus(caseId: caseId), plugins: [ClientAttestationPlugin(clientAttestation: clientAttestation.rawJWS)])
  }

  func fetchLegalRepresentantVerification(for requestCaseId: String) async throws -> LegalRepresentantVerificationResponse {
    let clientAttestation = try await clientAttestationRepository.get(using: userContext())

    do {
      return try await networkService.request(
        SIDRepositoryEndpoint.legalRepresentantVerification(caseId: requestCaseId),
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
      try await networkService.request(SIDRepositoryEndpoint.validateAttestations(requestBody))
    } catch let error as NetworkError where error.status == .unprocessableEntity {
      throw try parseError(error)
    } catch {
      throw Error.unknownError
    }
  }

  func startOnlineSession(caseId: String) async throws {
    let clientAttestationPlugin = try await generateClientAttestationPlugin(for: EIDRequestEmptyBody())

    do {
      try await networkService.request(SIDRepositoryEndpoint.startOnlineSession(caseId: caseId), plugins: [clientAttestationPlugin])
    } catch let error as NetworkError {
      throw try parseError(error)
    }
  }

  func pairWallet(caseId: String) async throws -> WalletPairingResponse {
    let clientAttestationPlugin = try await generateClientAttestationPlugin(for: EIDRequestEmptyBody())

    return try await networkService.request(SIDRepositoryEndpoint.pairWallet(caseId: caseId), plugins: [clientAttestationPlugin])
  }

  func startAutoVerification(caseId: String, autoVerificationType: AutoVerificationType, isNFCAvailable: Bool) async throws -> AutoVerificationResponse {
    let clientAttestationPlugin = try await generateClientAttestationPlugin(for: EIDRequestEmptyBody())

    return try await networkService.request(SIDRepositoryEndpoint.startAutoVerification(caseId: caseId, autoVerificationType: autoVerificationType, isNFCAvailable: isNFCAvailable), plugins: [clientAttestationPlugin])
  }

  func getPairingState(caseId: String, pairingId: String) async throws -> WalletPairingState {
    let clientAttestationPlugin = try await generateClientAttestationPlugin(for: EIDRequestEmptyBody())
    let response: WalletPairingStateResponse = try await networkService.request(SIDRepositoryEndpoint.pairingState(caseId: caseId, pairingId: pairingId), plugins: [clientAttestationPlugin])
    return response.state
  }

  func registerPushId(_ body: PushIdRegistrationBody, caseId: String) async throws {
    let clientAttestationPlugin = try await generateClientAttestationPlugin(for: body)

    try await networkService.request(SIDRepositoryEndpoint.registerPushId(caseId: caseId, body: body), plugins: [clientAttestationPlugin])
  }

  func abortRequestCase(for caseId: String) async throws {
    let clientAttestationPlugin = try await generateClientAttestationPlugin(for: EIDRequestEmptyBody())
    try await networkService.request(SIDRepositoryEndpoint.abort(caseId: caseId), plugins: [clientAttestationPlugin])
  }

  // MARK: Private

  @Injected(\.sidBaseUrl) private var sidBaseUrl
  @Injected(\NetworkContainer.service) private var networkService
  @Injected(\.eIDRequestResponseDecoder) private var eIDRequestResponseDecoder
  @Injected(\.proofOfPossessionGenerator) private var proofOfPossessionGenerator
  @Injected(\.clientAttestationRepository) private var clientAttestationRepository
  @Injected(\.userSession) private var userSession

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
    let clientAttestation = try await clientAttestationRepository.get(using: userContext())
    let proofOfPossession = try await proofOfPossessionGenerator(
      for: body,
      audience: sidBaseUrl.absoluteString,
      challengeEndpoint: URL(target: SIDRepositoryEndpoint.challenge),
      clientAttestation: clientAttestation)

    return ClientAttestationPlugin(clientAttestation: clientAttestation.rawJWS, proofOfPossession: proofOfPossession.rawJWS)
  }

  private func userContext() throws -> LAContextProtocol {
    guard userSession.isLoggedIn, let context = userSession.context else {
      throw UserSessionError.notLoggedIn
    }

    return context
  }
}

// MARK: SIDRepository.Error

extension SIDRepository {
  enum Error: Swift.Error {
    case invalidClientAttestation
    case invalidKeyAttestation
    case insufficientKeyStorageResistance
    case legalRepresentantNotRequired
    case unknownError
    case invalidState
  }
}


extension SIDRepository {
  /// Empty codable struct to generate a Proof of Possesion without body
  fileprivate struct EIDRequestEmptyBody: Codable { }
}
