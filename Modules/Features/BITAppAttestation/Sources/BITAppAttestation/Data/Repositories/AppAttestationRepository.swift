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
  func fetchKeyAttestation(with request: ClientAttestedRequest) async throws -> KeyAttestation
}

// MARK: - AppAttestationRepository

struct AppAttestationRepository: AppAttestationRepositoryProtocol {

  // MARK: Internal

  func fetchChallenge() async throws -> AttestationChallenge {
    let response = try await networkService.request(AttestationServiceEndpoint.challenge)
    return try JSONDecoder().decode(AttestationChallenge.Response.self, from: response.data).challenge
  }

  func fetchClientAttestation(_ requestBody: ClientAttestationRequestBody) async throws -> ClientAttestation {
    let response = try await networkService.request(AttestationServiceEndpoint.clientAttestation(requestBody))
    let clientAttestationResponse = try JSONDecoder().decode(ClientAttestationResponse.self, from: response.data)

    return try jwsDecoder.decode(ClientAttestationPayload.self, from: clientAttestationResponse.clientAttestation.data(using: .utf8) ?? Data())
  }

  func fetchKeyAttestation(with request: ClientAttestedRequest) async throws -> KeyAttestation {
    let response = try await networkService.request(AttestationServiceEndpoint.keyAttestation(request))
    let keyAttestationResponse = try JSONDecoder().decode(KeyAttestationResponse.self, from: response.data)

    return try jwsDecoder.decode(KeyAttestationPayload.self, from: keyAttestationResponse.keyAttestation.data(using: .utf8) ?? Data())
  }

  // MARK: Private

  @Injected(\.jwsDecoder) private var jwsDecoder: JWSDecoderProtocol
  @Injected(\NetworkContainer.service) private var networkService: NetworkService
}
