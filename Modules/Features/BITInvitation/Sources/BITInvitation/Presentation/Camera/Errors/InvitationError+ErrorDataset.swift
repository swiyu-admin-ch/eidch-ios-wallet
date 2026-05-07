import BITL10n
import BITOpenID
import BITTheming

extension InvitationError {

  // MARK: Internal

  var errorDataset: ErrorDataset? {
    switch self {
    case .oAuth(let openIDError):
      let rawErrorCode = getRawErrorCode(from: openIDError)
      return makeErrorDataSet(rawErrorCode: rawErrorCode, errorDescription: openIDError.invitationErrorDescription)
    case .credentialRequest(let openIDError):
      let rawErrorCode = getRawErrorCode(from: openIDError)
      return makeErrorDataSet(rawErrorCode: rawErrorCode, errorDescription: openIDError.invitationErrorDescription)
    default: return nil
    }
  }

  // MARK: Private

  private func getRawErrorCode(from openIDError: OpenIdRepositoryError) -> String? {
    switch openIDError {
    case .invalidRequest(let code): code
    case .unauthorizedClient(let code): code
    case .invalidScope(let code): code
    case .invalidClient(let code): code
    case .invalidGrant(let code): code
    case .unsupportedGrantType(let code): code
    case .invalidToken(let code): code
    case .insufficientScope(let code): code
    case .invalidCredentialRequest(let code): code
    case .unknownCredentialConfiguration(let code): code
    case .unknownCredentialIdentifier(let code): code
    case .invalidProof(let code): code
    case .invalidNonce(let code): code
    case .invalidEncryptionParameters(let code): code
    case .credentialRequestDenied(let code): code
    case .invalidTransactionId(let code): code
    default: nil
    }
  }

  private func makeErrorDataSet(rawErrorCode: String?, errorDescription: String?) -> ErrorDataset {
    var content: [InformationView2.ContentType] = [
      .title(L10n.tkCredentialOfferErrorPrimary),
      .body(L10n.tkCredentialOfferErrorSecondary),
    ]
    if let rawErrorCode {
      content.append(.caption(rawErrorCode))
    }
    if let errorDescription {
      content.append(.caption(errorDescription))
    }
    return ErrorDataset(content)
  }
}

extension OpenIdRepositoryError {

  fileprivate var invitationErrorDescription: String? {
    switch self {
    case .invalidRequest:
      L10n.tkCredentialOfferErrorInvalidRequestDescription
    case .invalidClient:
      L10n.tkCredentialOfferErrorInvalidClientDescription
    case .invalidGrant:
      L10n.tkCredentialOfferErrorInvalidGrantDescription
    case .unauthorizedClient:
      L10n.tkCredentialOfferErrorUnauthorizedClientDescription
    case .unsupportedGrantType:
      L10n.tkCredentialOfferErrorUnsupportedGrantTypeDescription
    case .invalidScope:
      L10n.tkCredentialOfferErrorInvalidScopeDescription
    case .credentialRequestDenied:
      L10n.tkCredentialOfferErrorCredentialRequestDeniedDescription
    case .invalidCredentialRequest:
      L10n.tkCredentialOfferErrorInvalidCredentialRequestDescription
    case .invalidEncryptionParameters:
      L10n.tkCredentialOfferErrorInvalidEncryptionParametersDescription
    case .invalidNonce:
      L10n.tkCredentialOfferErrorInvalidNonceDescription
    case .invalidProof:
      L10n.tkCredentialOfferErrorInvalidProofDescription
    case .unknownCredentialConfiguration:
      L10n.tkCredentialOfferErrorUnknownCredentialConfigurationDescription
    case .unknownCredentialIdentifier:
      L10n.tkCredentialOfferErrorUnknownCredentialIdentifierDescription
    case .invalidTransactionId:
      L10n.tkCredentialOfferErrorInvalidTransactionIdDescription
    case .invalidToken:
      L10n.tkCredentialOfferErrorInvalidTokenDescription
    case .insufficientScope:
      L10n.tkCredentialOfferErrorInsufficientScopeDescription
    default:
      nil
    }
  }
}
