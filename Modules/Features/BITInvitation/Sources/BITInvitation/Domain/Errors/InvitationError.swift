import BITCredential
import BITNetworking
import BITOpenID
import BITPresentation
import Foundation

// MARK: - InvitationError

public enum InvitationError: Error, Equatable {
  /// network
  case noConnection
  case oAuth(OpenIdRepositoryError)

  /// credential
  case expiredInvitation
  case unknownIssuer
  case validationFailed
  case invalidQRCode
  case credentialRequest(OpenIdRepositoryError)

  /// presentation
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

    if let openIdError = error as? OpenIdRepositoryError {
      switch openIdError {
      case .expiredAccessToken:
        return InvitationError.expiredInvitation
      case .invalidCredential:
        return InvitationError.validationFailed
      case
        .insufficientScope,
        .invalidClient,
        .invalidGrant,
        .invalidRequest,
        .invalidScope,
        .invalidToken,
        .unauthorizedClient,
        .unsupportedGrantType:
        return InvitationError.oAuth(openIdError)
      case
        .credentialRequestDenied,
        .invalidCredentialRequest,
        .invalidEncryptionParameters,
        .invalidNonce,
        .invalidProof,
        .invalidTransactionId,
        .unknownCredentialConfiguration,
        .unknownCredentialIdentifier:
        return InvitationError.credentialRequest(openIdError)
      case
        .invalidCredentialIssuerMetadata,
        .invalidCredentialIssuerMetadataJWT,
        .invalidOpenIdConfigurationJWT,
        .missingCredentialResponsePrivateKey,
        .missingDeferredCredentialEndpoint,
        .missingImmediateCredentialData,
        .unsupportedCredentialStatusCode:
        return InvitationError.invalidQRCode
      }
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
      case .expiredRequest,
           .invalidRequest:
        return InvitationError.invalidPresentationRequest
      case .invalidUrl:
        return InvitationError.invalidQRCode
      }
    }

    return InvitationError.invalidQRCode
  }
}
