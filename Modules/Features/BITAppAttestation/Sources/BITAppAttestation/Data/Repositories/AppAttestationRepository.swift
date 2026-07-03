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
      throw AppAttestationRepositoryError.invalidClientAttestation
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

      return try jwsDecoder.decode(KeyAttestationJWT.self, from: keyAttestationResponse.keyAttestation.data(using: .utf8) ?? Data())
    } catch {
      throw mapError(error)
    }
  }

  // MARK: Private

  private let errorMap: [NetworkErrorStatus: any Error] = [
    .serviceDeactivated: AppAttestationRepositoryError.serviceDeactivated,
    .serviceUnavailable: AppAttestationRepositoryError.serviceDeactivated,
    .timeout: AppAttestationRepositoryError.timeout,
  ]
  @Injected(\.jwsDecoder) private var jwsDecoder: JWSDecoderProtocol
  @Injected(\NetworkContainer.service) private var networkService: NetworkService
  @Injected(\.proofOfPossessionGenerator) private var proofOfPossessionGenerator: ProofOfPossessionGeneratorProtocol
  @Injected(\.didResolverHelper) private var didResolverHelper: DidResolverHelperProtocol

  private func mapError(_ error: Error) -> Error {
    guard let networkError = error as? NetworkError else {
      return error
    }

    return errorMap[networkError.status] ?? error
  }
}

// MARK: - AppAttestationRepositoryError

public enum AppAttestationRepositoryError: Error {
  case invalidBindingKey
  case invalidKeyAttestation
  case invalidClientAttestation
  case timeout
  case serviceDeactivated
}
