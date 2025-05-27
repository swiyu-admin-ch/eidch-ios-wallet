import BITCredential
import BITNetworking
import BITOpenID
import BITPresentation
import Foundation

// MARK: - InvitationError

enum InvitationError: Error {
  // Network related errors
  case noConnection
  case invalidQRCode

  // Credential related errors
  case expiredInvitation
  case unknownIssuer
  case validationFailed
  case emptyWallet
  case compatibleCredentialNotFound

  // Presentation related errors
  case invalidPresentationRequest
}

extension InvitationError {
  static func from(_ error: Error) -> InvitationError {
    if let networkError = error as? NetworkError {
      switch networkError.status {
      case .noConnection:
        return .noConnection
      default:
        return .invalidQRCode
      }
    }

    if let fetchError = error as? FetchAnyVerifiableCredentialError {
      switch fetchError {
      case .expiredInvitation:
        return .expiredInvitation
      case .unknownIssuer:
        return .unknownIssuer
      case .validationFailed:
        return .validationFailed
      case .credentialEndpointCreationError,
           .invalidVcSchema,
           .missingTypeMetadata,
           .missingVctIntegrity,
           .selectedCredentialNotFound,
           .typeMetadataInvalidIntegrity,
           .unsupportedAlgorithm,
           .vctMismatch:
        return .invalidQRCode
      }
    }

    if let credentialsError = error as? CompatibleCredentialsError {
      switch credentialsError {
      case .emptyWallet:
        return .emptyWallet
      case .compatibleCredentialNotFound:
        return .compatibleCredentialNotFound
      }
    }

    if let fetchError = error as? FetchRequestObjectError {
      switch fetchError {
      case .expired:
        return .expiredInvitation
      case .invalid:
        return .invalidPresentationRequest
      }
    }

    return .invalidQRCode
  }
}
