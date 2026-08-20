import BITCrypto
import BITJWT
import BITNetworking
import Factory
import Foundation
import Spyable

// MARK: - AttestationServiceRepositoryProtocol

@Spyable
public protocol AttestationServiceRepositoryProtocol {
  func fetchChallenge() async throws -> AttestationChallenge
  func fetchClientAttestation(_ requestBody: ClientAttestationRequestBody) async throws -> ClientAttestation
  func fetchKeyAttestation(body: KeyAttestationRequestBody, clientAttestation: ClientAttestation) async throws -> KeyAttestation
  func fetchBatchKeyAttestation(body: [KeyAttestationRequestBody], clientAttestation: ClientAttestation) async throws -> [KeyAttestation]
}

// MARK: - AttestationServiceRepository

struct AttestationServiceRepository: AttestationServiceRepositoryProtocol {

  // MARK: Internal

  func fetchChallenge() async throws -> AttestationChallenge {
    do {
      let response = try await networkService.request(AttestationServiceEndpoint.challenge)
      return try JSONDecoder().decode(AttestationChallenge.Response.self, from: response.data).challenge
    } catch {
      throw mapError(error)
    }
  }

  func fetchClientAttestation(_ requestBody: ClientAttestationRequestBody) async throws -> ClientAttestation {
    do {
      let response = try await networkService.request(AttestationServiceEndpoint.clientAttestation(requestBody))
      let clientAttestationResponse = try JSONDecoder().decode(ClientAttestationResponse.self, from: response.data)

      return try jwsDecoder.decode(ClientAttestationJWT.self, from: clientAttestationResponse.clientAttestation.data(using: .utf8) ?? Data())
    } catch let error as NetworkError where error.status == .badRequest {
      throw AttestationServiceRepositoryError.invalidClientAttestation
    } catch {
      throw mapError(error)
    }
  }

  func fetchKeyAttestation(body: KeyAttestationRequestBody, clientAttestation: ClientAttestation) async throws -> KeyAttestation {
    do {
      let audience = try didResolverHelper.getDid(from: clientAttestation.header.keyIdentifier)
      let proofOfPossession = try await proofOfPossessionGenerator(
        for: body,
        audience: audience,
        challengeEndpoint: URL(target: AttestationServiceEndpoint.challenge),
        clientAttestation: clientAttestation)

      let keyAttestationResponse: KeyAttestationResponse = try await networkService.request(
        AttestationServiceEndpoint.keyAttestation(body),
        plugins: [
          ClientAttestationPlugin(
            clientAttestation: clientAttestation.rawJWS,
            proofOfPossession: proofOfPossession.rawJWS),
        ])

      return try decodeKeyAttestation(keyAttestationResponse.keyAttestation)
    } catch {
      throw mapError(error)
    }
  }

  func fetchBatchKeyAttestation(body: [KeyAttestationRequestBody], clientAttestation: ClientAttestation) async throws -> [KeyAttestation] {
    if body.isEmpty {
      return []
    }

    do {
      let audience = try didResolverHelper.getDid(from: clientAttestation.header.keyIdentifier)
      let requestBody = BatchKeyAttestationRequestBody(body)
      let proofOfPossession = try await proofOfPossessionGenerator(
        for: requestBody,
        audience: audience,
        challengeEndpoint: URL(target: AttestationServiceEndpoint.challenge),
        clientAttestation: clientAttestation)

      let response: BatchKeyAttestationResponse = try await networkService.request(
        AttestationServiceEndpoint.batchKeyAttestations(requestBody),
        plugins: [
          ClientAttestationPlugin(
            clientAttestation: clientAttestation.rawJWS,
            proofOfPossession: proofOfPossession.rawJWS),
        ])

      var keyAttestations = [Int: KeyAttestation]()

      for keyAttestation in response.keyAttestations {
        guard keyAttestations[keyAttestation.id] == nil else {
          throw AttestationServiceRepositoryError.invalidKeyAttestation
        }

        keyAttestations[keyAttestation.id] = try decodeKeyAttestation(keyAttestation.response)
      }

      guard keyAttestations.count == requestBody.keys.count else {
        throw AttestationServiceRepositoryError.invalidKeyAttestation
      }

      return try requestBody.keys.map {
        guard let keyAttestation = keyAttestations[$0.id] else {
          throw AttestationServiceRepositoryError.invalidKeyAttestation
        }

        return keyAttestation
      }
    } catch {
      throw mapError(error)
    }
  }

  // MARK: Private

  private let errorMap: [NetworkErrorStatus: any Error] = [
    .serviceDeactivated: AttestationServiceRepositoryError.serviceDeactivated,
    .serviceUnavailable: AttestationServiceRepositoryError.serviceDeactivated,
    .timeout: AttestationServiceRepositoryError.timeout,
  ]
  @Injected(\.jwsDecoder) private var jwsDecoder: JWSDecoderProtocol
  @Injected(\NetworkContainer.service) private var networkService: NetworkService
  @Injected(\.proofOfPossessionGenerator) private var proofOfPossessionGenerator: ProofOfPossessionGeneratorProtocol
  @Injected(\.didResolverHelper) private var didResolverHelper: DidResolverHelperProtocol

  private func decodeKeyAttestation(_ keyAttestation: String) throws -> KeyAttestation {
    try jwsDecoder.decode(KeyAttestationJWT.self, from: keyAttestation.data(using: .utf8) ?? Data())
  }

  private func mapError(_ error: Error) -> Error {
    guard let networkError = error as? NetworkError else {
      return error
    }

    return errorMap[networkError.status] ?? error
  }
}

// MARK: - AttestationServiceRepositoryError

public enum AttestationServiceRepositoryError: Error, Equatable {
  case invalidBindingKey
  case invalidKeyAttestation
  case invalidClientAttestation
  case timeout
  case serviceDeactivated
}
