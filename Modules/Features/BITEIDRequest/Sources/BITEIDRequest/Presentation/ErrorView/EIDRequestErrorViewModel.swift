import BITL10n
import BITPresentation
import Spyable
import SwiftUI


@Spyable
public protocol EIDRequestErrorDelegate: AnyObject {
  func primaryAction(error: Error)
  func close()
}


class EIDRequestErrorViewModel {

  // MARK: Lifecycle

  init(delegate: EIDRequestErrorDelegate, error: Error) {
    self.delegate = delegate
    self.error = error
  }

  // MARK: Internal

  var primaryText: String {
    switch error {
    case CompatibleCredentialsError.compatibleCredentialNotFound,
         CompatibleCredentialsError.emptyWallet:
      L10n.tkEidRequestErrorNoCredentialPrimary
    case EIDRequestRepository.Error.invalidState:
      L10n.tkEidRequestErrorInvalidStatePrimary
    case EIDRequestRepository.Error.unknownError:
      L10n.tkEidRequestErrorUnknownPrimary
    default: L10n.tkEidRequestErrorGenericPrimary
    }
  }

  var secondaryText: String {
    switch error {
    case CompatibleCredentialsError.compatibleCredentialNotFound,
         CompatibleCredentialsError.emptyWallet:
      L10n.tkEidRequestErrorNoCredentialSecondary
    case EIDRequestRepository.Error.invalidState:
      L10n.tkEidRequestErrorInvalidStateSecondary
    case EIDRequestRepository.Error.unknownError:
      L10n.tkEidRequestErrorUnknownSecondary
    default: L10n.tkEidRequestErrorGenericSecondary
    }
  }

  var buttonText: String {
    switch error {
    case CompatibleCredentialsError.compatibleCredentialNotFound,
         CompatibleCredentialsError.emptyWallet:
      L10n.tkEidRequestErrorNoCredentialButton
    case EIDRequestRepository.Error.invalidState:
      L10n.tkEidRequestErrorInvalidStateButton
    case EIDRequestRepository.Error.unknownError:
      L10n.tkEidRequestErrorUnknownButton
    default: L10n.tkEidRequestErrorGenericButton
    }
  }

  func primaryAction() {
    delegate?.primaryAction(error: error)
  }

  func close() {
    delegate?.close()
  }

  // MARK: Private

  weak private var delegate: EIDRequestErrorDelegate?

  private let error: Error
}
