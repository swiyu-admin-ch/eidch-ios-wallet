import BITNetworking
import Foundation
import Spyable

// MARK: - OpenID4VCIErrorParserProtocol

@Spyable
protocol OpenID4VCIErrorParserProtocol {
  func parse(_ error: Error) -> Error
}

// MARK: - OpenID4VCIErrorParser

struct OpenID4VCIErrorParser: OpenID4VCIErrorParserProtocol {

  func parse(_ error: Error) -> Error {
    guard let networkError = error as? NetworkError else {
      return error
    }

    switch networkError.status {
    case .unauthorized:
      return OpenIdRepositoryError.expiredAccessToken

    case .badRequest:
      guard
        let data = networkError.response?.data,
        let response = try? JSONDecoder().decode(CredentialResponseError.self, from: data)
      else {
        return error
      }

      switch response.error {
      case .credentialRequestDenied:
        return OpenIdRepositoryError.invalidCredential
      case .invalidCredentialRequest:
        return OpenIdRepositoryError.invalidCredentialRequest(response.error.rawValue)
      case .invalidEncryptionParameters:
        return OpenIdRepositoryError.invalidEncryptionParameters(response.error.rawValue)
      case .invalidNonce:
        return OpenIdRepositoryError.invalidNonce(response.error.rawValue)
      case .invalidProof:
        return OpenIdRepositoryError.invalidProof(response.error.rawValue)
      case .unknownCredentialConfiguration:
        return OpenIdRepositoryError.unknownCredentialConfiguration(response.error.rawValue)
      case .unknownCredentialIdentifier:
        return OpenIdRepositoryError.unknownCredentialIdentifier(response.error.rawValue)
      case .invalidTransactionId:
        return OpenIdRepositoryError.invalidTransactionId(response.error.rawValue)
      case .invalidRequest:
        return OpenIdRepositoryError.invalidRequest(response.error.rawValue)
      case .invalidToken:
        return OpenIdRepositoryError.invalidToken(response.error.rawValue)
      case .insufficientScope:
        return OpenIdRepositoryError.insufficientScope(response.error.rawValue)
      }

    default:
      return error
    }
  }
}
