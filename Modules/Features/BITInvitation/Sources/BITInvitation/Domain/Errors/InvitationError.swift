import BITCredential
import BITNetworking
import BITOpenID
import BITPresentation
import Foundation

// MARK: - InvitationError

public enum InvitationError: Error {
  // Network related errors
  case noConnection
  case invalidQRCode

  // Credential related errors
  case expiredInvitation
  case unknownIssuer
  case validationFailed

  /// Presentation related errors
  case invalidPresentationRequest
}

// MARK: - InvitationErrorMapping

public protocol InvitationErrorMapping {
  func callAsFunction(_ error: Error) -> Error
}

// MARK: - InvitationErrorMapper

public struct InvitationErrorMapper: InvitationErrorMapping {

  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public func callAsFunction(_ error: Error) -> Error {
    if let invitationError = error as? InvitationError {
      return invitationError
    }

    if let networkError = error as? NetworkError {
      switch networkError.status {
      case .noConnection,
           .timeout:
        return InvitationError.noConnection
      default:
        return InvitationError.invalidQRCode
      }
    }

    if let fetchError = error as? FetchAnyVerifiableCredentialError {
      switch fetchError {
      case .expiredInvitation:
        return InvitationError.expiredInvitation
      case .unknownIssuer:
        return InvitationError.unknownIssuer
      case .validationFailed:
        return InvitationError.validationFailed
      case .credentialEndpointCreationError,
           .invalidVcSchema,
           .missingTypeMetadata,
           .missingVctIntegrity,
           .selectedCredentialNotFound,
           .typeMetadataInvalidIntegrity,
           .unsupportedAlgorithm,
           .unsupportedKeyStorage,
           .vctMismatch:
        return InvitationError.invalidQRCode
      }
    }

    if let fetchError = error as? FetchPresentationRequestUseCaseError {
      switch fetchError {
      case .expiredRequest:
        return InvitationError.expiredInvitation
      case .invalidRequest:
        return InvitationError.invalidPresentationRequest
      case .invalidUrl:
        return InvitationError.invalidQRCode
      }
    }

    return InvitationError.invalidQRCode
  }
}
