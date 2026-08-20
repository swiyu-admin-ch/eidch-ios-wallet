import BITL10n
import BITOpenID
import BITTheming

extension InvitationError {

  // MARK: Internal

  var errorDataset: ErrorDataset? {
    switch self {
    case .oAuth(let openIDError):
      let rawErrorCode = getRawErrorCode(from: openIDError)
      return makeIssuanceErrorDataSet(rawErrorCode: rawErrorCode, errorDescription: openIDError.invitationErrorDescription)
    case .credentialRequest(let openIDError):
      let rawErrorCode = getRawErrorCode(from: openIDError)
      return makeIssuanceErrorDataSet(rawErrorCode: rawErrorCode, errorDescription: openIDError.invitationErrorDescription)
    case .invalidPresentationRequest(let rawErrorCode):
      return makePresentationErrorDataset(rawErrorCode: rawErrorCode, errorDescription: getPresentationErrorDescription(for: rawErrorCode))
    case .transactionDataNotSupported(let rawErrorCode):
      return makePresentationErrorDataset(rawErrorCode: rawErrorCode, errorDescription: L10n.tkPresentErrorInvalidTransactionDataSecondary)
    case .invalidRedirectUri:
      return invalidRedirectUriDataSet()
    case .unverifiedActor:
      return makeGovernanceErrorDataSet(
        rawErrorCode: GovernanceError.unverifiedActor.rawValue,
        errorDescription: L10n.tkCredentialOfferErrorUnverifiedIssuerDescription)
    case .unknownRegistry:
      return makeGovernanceErrorDataSet(
        rawErrorCode: GovernanceError.unknownRegistry.rawValue,
        errorDescription: L10n.tkGovErrorUnknownRegistryDescription)
    case .unauthorizedIssuance:
      return makeGovernanceErrorDataSet(
        rawErrorCode: GovernanceError.unauthorizedIssuance.rawValue,
        errorDescription: L10n.tkCredentialOfferErrorUnauthorizedIssuanceDescription)
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
    case .invalidDPoPProof(let code): code
    case .useDPoPNonce(let code, _): code
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

  private func makeIssuanceErrorDataSet(rawErrorCode: String?, errorDescription: String?) -> ErrorDataset {
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

  private func makeGovernanceErrorDataSet(rawErrorCode: String, errorDescription: String) -> ErrorDataset {
    .governanceError(rawErrorCode: rawErrorCode, errorDescription: errorDescription)
  }

  private func makePresentationErrorDataset(rawErrorCode: String, errorDescription: String) -> ErrorDataset {
    ErrorDataset([
      .title(L10n.tkPresentErrorPrimary),
      .body(L10n.tkPresentErrorSecondary),
      .caption(rawErrorCode),
      .caption(errorDescription),
    ])
  }

  private func getPresentationErrorDescription(for rawErrorCode: String) -> String {
    switch rawErrorCode {
    case GovernanceError.unverifiedActor.rawValue:
      L10n.tkPresentErrorUnverifiedVerifierSecondary
    case GovernanceError.unknownRegistry.rawValue:
      L10n.tkGovErrorUnknownRegistryDescription
    case GovernanceError.invalidEnvironment.rawValue:
      L10n.tkGovErrorInvalidEnvironmentDescription
    default:
      L10n.tkPresentErrorSecondary
    }
  }

  private func invalidRedirectUriDataSet() -> ErrorDataset {
    ErrorDataset([
      .title(L10n.tkErrorRedirectUriInvalidPrimary),
      .body(L10n.tkErrorRedirectUriInvalidSecondary),
    ])
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
