import BITAppAttestation
import BITAppAuth
import BITNetworking
import Factory
import Foundation
import Spyable

// MARK: - PushNotificationRepositoryProtocol

@Spyable
public protocol PushNotificationRepositoryProtocol {
  func delete(pushId: String) async throws
  func register(body: PushRegistrationBody) async throws -> PushRegistrationResponse

  @discardableResult
  func update(body: PushUpdateBody) async throws -> PushUpdateResponse
}

// MARK: - PushNotificationRepository

struct PushNotificationRepository: PushNotificationRepositoryProtocol {

  // MARK: Internal

  func delete(pushId: String) async throws {
    let clientAttestationPlugin = try await generateClientAttestationPlugin(for: EmptyBody())
    try await networkService.request(PushNotificationServiceEndpoint.delete(pushId: pushId), plugins: [clientAttestationPlugin])
  }

  func register(body: PushRegistrationBody) async throws -> PushRegistrationResponse {
    let clientAttestationPlugin = try await generateClientAttestationPlugin(for: body)
    return try await networkService.request(PushNotificationServiceEndpoint.register(body), plugins: [clientAttestationPlugin])
  }

  func update(body: PushUpdateBody) async throws -> PushUpdateResponse {
    let clientAttestationPlugin = try await generateClientAttestationPlugin(for: body)
    return try await networkService.request(PushNotificationServiceEndpoint.update(body), plugins: [clientAttestationPlugin])
  }

  // MARK: Private

  @Injected(\.userSession) private var userSession: Session
  @Injected(\NetworkContainer.service) private var networkService: NetworkService
  @Injected(\.pushNotificationUrl) private var pushNotificationUrl: URL
  @Injected(\.proofOfPossessionGenerator) private var proofOfPossessionGenerator: ProofOfPossessionGeneratorProtocol
  @Injected(\.clientAttestationRepository) private var clientAttestationRepository: ClientAttestationRepositoryProtocol

  private func generateClientAttestationPlugin(for body: Encodable) async throws -> ClientAttestationPlugin {
    guard userSession.isLoggedIn, let context = userSession.context else {
      throw PushNotificationRepositoryError.invalidSession
    }

    let clientAttestation = try await clientAttestationRepository.get(using: context)
    let proofOfPossession = try await proofOfPossessionGenerator(
      for: body,
      challengeEndpoint: PushNotificationServiceChallengeEndpoint.url,
      clientAttestation: clientAttestation)

    return ClientAttestationPlugin(clientAttestation: clientAttestation.rawJWS, proofOfPossession: proofOfPossession.rawJWS)
  }
}

// MARK: - PushNotificationRepositoryError

enum PushNotificationRepositoryError: Error {
  case invalidSession
}

// MARK: - PushNotificationRepository.EmptyBody

extension PushNotificationRepository {
  private struct EmptyBody: Encodable { }
}
