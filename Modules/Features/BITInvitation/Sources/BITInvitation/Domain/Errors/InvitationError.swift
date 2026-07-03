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
  case invalidPresentationRequest(String)
  case transactionDataNotSupported(String)
  case notFoundPresentationRequest
  case expiredPresentationRequest
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
      case .invalidCredential:
        return InvitationError.validationFailed
      case
        .expiredAccessToken,
        .insufficientScope,
        .invalidClient,
        .invalidDPoPProof,
        .invalidGrant,
        .invalidRequest,
        .invalidScope,
        .invalidToken,
        .unauthorizedClient,
        .unsupportedGrantType,
        .useDPoPNonce:
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
           .unsupportedAlgorithm,
           .unsupportedKeyStorage,
           .vctMismatch:
        return InvitationError.invalidQRCode
      }
    }

    if let typeMetadataError = error as? VcMetadataForVcSdJwtError {
      return InvitationError.invalidQRCode
    }

    if let fetchError = error as? FetchPresentationRequestUseCaseError {
      switch fetchError {
      case .invalidUrl:
        return InvitationError.invalidQRCode
      case .invalidRequest(let errorCode):
        return InvitationError.invalidPresentationRequest(errorCode)
      case .transactionDataNotSupported(let errorCode):
        return InvitationError.transactionDataNotSupported(errorCode)
      case .expired:
        return InvitationError.expiredPresentationRequest
      case .notFound:
        return InvitationError.notFoundPresentationRequest
      }
    }

    return InvitationError.invalidQRCode
  }
}
