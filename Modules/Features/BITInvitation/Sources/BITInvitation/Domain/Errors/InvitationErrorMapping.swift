import BITNetworking
import BITOpenID
import Foundation

// MARK: - InvitationErrorMapping

protocol InvitationErrorMapping {
  func callAsFunction(_ error: Error) -> Error
}

// MARK: - InvitationErrorMapper

struct InvitationErrorMapper: InvitationErrorMapping {

  func callAsFunction(_ error: Error) -> Error {
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
        .unencryptedCredentialResponse,
        .unsupportedCredentialStatusCode:
        return InvitationError.invalidQRCode(openIdError)
      }
    }

    if let networkError = error as? NetworkError {
      switch networkError.status {
      case .noConnection,
           .timeout:
        return InvitationError.noConnection
      default:
        return InvitationError.invalidQRCode(networkError)
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
        return InvitationError.invalidQRCode(fetchError)
      }
    }

    if let fetchError = error as? FetchPresentationRequestUseCaseError {
      switch fetchError {
      case .invalidUrl:
        return InvitationError.invalidQRCode(fetchError)
      case .invalidRequest(let errorCode, _):
        return InvitationError.invalidPresentationRequest(errorCode)
      case .transactionDataNotSupported(let errorCode, _):
        return InvitationError.transactionDataNotSupported(errorCode)
      case .unverifiedActor:
        return InvitationError.invalidPresentationRequest(GovernanceError.unverifiedActor.rawValue)
      case .unknownRegistry:
        return InvitationError.invalidPresentationRequest(GovernanceError.unknownRegistry.rawValue)
      case .expired:
        return InvitationError.expiredPresentationRequest
      case .notFound:
        return InvitationError.notFoundPresentationRequest
      }
    }

    if let proximityError = error as? StartProximityEngagementUseCaseError {
      switch proximityError {
      case .invalidOrigin:
        return InvitationError.invalidQRCode(proximityError)
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

    if let governanceError = error as? GovernanceError {
      switch governanceError {
      case .unverifiedActor:
        return InvitationError.unverifiedActor
      case .unknownRegistry:
        return InvitationError.unknownRegistry
      case .unauthorizedIssuance:
        return InvitationError.unauthorizedIssuance
      default:
        break
      }
    }

    if let presentationResponseError = error as? PresentationResponseValidationError {
      switch presentationResponseError {
      case .invalidRedirectUri: return InvitationError.invalidRedirectUri
      }
    }

    return InvitationError.invalidQRCode(error)
  }
}
