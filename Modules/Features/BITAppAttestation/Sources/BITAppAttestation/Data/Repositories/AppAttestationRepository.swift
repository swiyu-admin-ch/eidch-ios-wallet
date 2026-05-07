import BITCrypto
import BITJWT
import BITNetworking
import Factory
import Foundation
import Spyable

// MARK: - AppAttestationRepositoryProtocol

@Spyable
public protocol AppAttestationRepositoryProtocol {
  func fetchChallenge() async throws -> AttestationChallenge
  func fetchClientAttestation(_ requestBody: ClientAttestationRequestBody) async throws -> ClientAttestation
  func fetchKeyAttestation(body: KeyAttestationRequestBody, clientAttestation: ClientAttestation) async throws -> KeyAttestation
}

// MARK: - AppAttestationRepository

struct AppAttestationRepository: AppAttestationRepositoryProtocol {

  // MARK: Internal

  func fetchChallenge() async throws -> AttestationChallenge {
    let response = try await networkService.request(AttestationServiceEndpoint.challenge)
    return try JSONDecoder().decode(AttestationChallenge.Response.self, from: response.data).challenge
  }

  func fetchClientAttestation(_ requestBody: ClientAttestationRequestBody) async throws -> ClientAttestation {
    do {
      let response = try await networkService.request(AttestationServiceEndpoint.clientAttestation(requestBody))
      let clientAttestationResponse = try JSONDecoder().decode(ClientAttestationResponse.self, from: response.data)

      return try jwsDecoder.decode(ClientAttestationJWT.self, from: clientAttestationResponse.clientAttestation.data(using: .utf8) ?? Data())
    } catch let error as NetworkError where error.status == .badRequest {
      throw AppAttestationRepositoryError.invalidClientAttestation
    }
  }

  func fetchKeyAttestation(body: KeyAttestationRequestBody, clientAttestation: ClientAttestation) async throws -> KeyAttestation {
    let proofOfPossession = try await proofOfPossessionGenerator(
      for: body,
      audience: clientAttestation.payload.issuer,
      challengeEndpoint: URL(target: AttestationServiceEndpoint.challenge),
      clientAttestation: clientAttestation)

    let keyAttestationResponse: KeyAttestationResponse = try await networkService.request(
      AttestationServiceEndpoint.keyAttestation(body),
      plugins: [
        ClientAttestationPlugin(
          clientAttestation: clientAttestation.rawJWS,
          proofOfPossession: proofOfPossession.rawJWS),
      ])

    return try jwsDecoder.decode(KeyAttestationJWT.self, from: keyAttestationResponse.keyAttestation.data(using: .utf8) ?? Data())
  }

  // MARK: Private

  @Injected(\.jwsDecoder) private var jwsDecoder: JWSDecoderProtocol
  @Injected(\NetworkContainer.service) private var networkService: NetworkService
  @Injected(\.proofOfPossessionGenerator) private var proofOfPossessionGenerator: ProofOfPossessionGeneratorProtocol
}

// MARK: - AppAttestationRepositoryError

public enum AppAttestationRepositoryError: Error {
  case invalidBindingKey
  case invalidKeyAttestation
  case invalidClientAttestation
}
