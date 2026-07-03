import BITNetworking
import Foundation
import Spyable

// MARK: - OAuthErrorParserProtocol

@Spyable
protocol OAuthErrorParserProtocol {
  func parse(_ error: Error) -> Error
}

// MARK: - OAuthErrorParser

struct OAuthErrorParser: OAuthErrorParserProtocol {

  // MARK: Internal

  func parse(_ error: Error) -> Error {
    guard let networkError = error as? NetworkError else {
      return error
    }

    switch networkError.status {
    case .badRequest,
         .invalidGrant,
         .unauthorized:
      guard
        let data = networkError.response?.data,
        let response = try? JSONDecoder().decode(TokenResponseError.self, from: data)
      else {
        return error
      }

      switch response.error {
      case .invalidRequest:
        return OpenIdRepositoryError.invalidRequest(response.error.rawValue)
      case .unauthorizedClient:
        return OpenIdRepositoryError.unauthorizedClient(response.error.rawValue)
      case .invalidScope:
        return OpenIdRepositoryError.invalidScope(response.error.rawValue)
      case .invalidClient:
        return OpenIdRepositoryError.invalidClient(response.error.rawValue)
      case .invalidGrant:
        return OpenIdRepositoryError.invalidGrant(response.error.rawValue)
      case .unsupportedGrantType:
        return OpenIdRepositoryError.unsupportedGrantType(response.error.rawValue)
      case .invalidDPoPProof:
        return OpenIdRepositoryError.invalidDPoPProof(response.error.rawValue)
      case .useDPoPNonce:
        let dpopNonce = networkError.response?.response?.value(forHTTPHeaderField: Self.dpopNonceHeaderField)
        return OpenIdRepositoryError.useDPoPNonce(response.error.rawValue, dpopNonce)
      }

    default:
      return error
    }
  }

  // MARK: Private

  private static let dpopNonceHeaderField = "DPoP-Nonce"

}
