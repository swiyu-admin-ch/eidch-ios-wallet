import BITAppAttestation
import BITAppAuth
import BITNetworking
import Factory
import Foundation
import Moya
import Spyable

// MARK: - OTPRequestRepositoryProtocol

@Spyable
protocol OTPRequestRepositoryProtocol {
  func requestOTP(email: String) async throws
  func verifyOTP(email: String, code: String) async throws
}

// MARK: - OTPRequestRepository

struct OTPRequestRepository: OTPRequestRepositoryProtocol {

  // MARK: Internal

  func requestOTP(email: String) async throws {
    let body = OTPRequestBody(email: email)
    try await executeRequest(for: .request(body), body: body, errorMapper: mapRequestError)
  }

  func verifyOTP(email: String, code: String) async throws {
    let body = OTPVerifyBody(email: email, code: code)
    try await executeRequest(for: .verify(body), body: body, errorMapper: mapVerifyError)
  }

  // MARK: Private

  @Injected(\NetworkContainer.service) private var networkService
  @Injected(\.otpServiceBaseUrl) private var otpServiceBaseUrl
  @Injected(\.proofOfPossessionGenerator) private var proofOfPossessionGenerator
  @Injected(\.clientAttestationRepository) private var clientAttestationRepository
  @Injected(\.userSession) private var userSession

  private func executeRequest(
    for endpoint: OTPEndpoint,
    body: Encodable,
    errorMapper: (NetworkError) -> OTPError) async throws
  {
    let clientAttestationPlugin = try await generateClientAttestationPlugin(for: body)

    do {
      try await networkService.request(endpoint, plugins: [clientAttestationPlugin])
    } catch let error as NetworkError {
      throw errorMapper(error)
    } catch {
      throw OTPError.unknown
    }
  }

  private func generateClientAttestationPlugin(for body: Encodable) async throws -> ClientAttestationPlugin {
    guard userSession.isLoggedIn, let context = userSession.context else {
      throw OTPError.invalidClientAttestation
    }

    do {
      let clientAttestation = try await clientAttestationRepository.get(using: context)
      let proofOfPossession = try await proofOfPossessionGenerator(
        for: body,
        audience: otpServiceBaseUrl.absoluteString,
        challengeEndpoint: AttestationChallengeEndpoint.url,
        clientAttestation: clientAttestation)

      return ClientAttestationPlugin(clientAttestation: clientAttestation.rawJWS, proofOfPossession: proofOfPossession.rawJWS)
    } catch {
      throw OTPError.invalidClientAttestation
    }
  }
}

extension OTPRequestRepository {

  private func mapRequestError(_ error: NetworkError) -> OTPError {
    switch error.status {
    case .badRequest,
         .invalidRequest:
      .invalidFormat
    case .unauthorized:
      .invalidClientAttestation
    case .forbidden:
      .forbiddenEmail
    default:
      switch error.response?.statusCode {
      case 418: .serviceDeactivated
      default: .unknown
      }
    }
  }

  private func mapVerifyError(_ error: NetworkError) -> OTPError {
    switch error.status {
    case .forbidden,
         .invalidRequest:
      .invalidFormat
    case .unauthorized:
      .invalidClientAttestation
    case .gone:
      .otpExpired
    default:
      switch error.response?.statusCode {
      case 418: .serviceDeactivated
      case 429: .tooManyRequests
      default: .unknown
      }
    }
  }

}
