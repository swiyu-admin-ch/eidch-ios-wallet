import BITL10n
import DeviceCheck
import Spyable
import SwiftUI

// MARK: - ValidateAttestationsErrorDelegate

@Spyable
protocol ValidateAttestationsErrorDelegate: AnyObject {
  func didTapPrimaryAction()
}

// MARK: - ValidateAttestationsErrorViewModel

class ValidateAttestationsErrorViewModel: ObservableObject {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes, delegate: ValidateAttestationsErrorDelegate, error: Error) {
    self.router = router
    self.delegate = delegate
    self.error = error
  }

  // MARK: Internal

  weak var delegate: ValidateAttestationsErrorDelegate?

  var primaryText: String {
    switch error {
    case EIDRequestRepository.Error.insufficientKeyStorageResistance:
      L10n.tkEidRequestClientAttestationInsufficientKeyStorageTitle
    case DCError.serverUnavailable:
      L10n.tkEidRequestClientAttestationDeviceCheckTimeoutTitle
    case is DCError:
      L10n.tkEidRequestClientAttestationDeviceCheckErrorTitle
    case FetchAttestationsUseCaseError.networkError:
      L10n.tkEidRequestClientAttestationServiceErrorTitle
    default:
      L10n.tkEidRequestAttestationUnknownErrorPrimary
    }
  }

  var secondaryText: String {
    switch error {
    case EIDRequestRepository.Error.insufficientKeyStorageResistance:
      L10n.tkEidRequestClientAttestationInsufficientKeyStorageBody
    case DCError.serverUnavailable:
      L10n.tkEidRequestClientAttestationDeviceCheckTimeoutBody
    case is DCError:
      L10n.tkEidRequestClientAttestationDeviceCheckErrorBody
    case FetchAttestationsUseCaseError.networkError:
      L10n.tkEidRequestClientAttestationServiceErrorBody
    default:
      L10n.tkEidRequestAttestationUnknownErrorSecondary
    }
  }

  var isRetryEnabled: Bool {
    switch error {
    case DCError.serverUnavailable,
         EIDRequestRepository.Error.unknownError:
      true
    case is DCError,
         EIDRequestRepository.Error.insufficientKeyStorageResistance:
      false
    default:
      true
    }
  }

  func primaryAction() {
    delegate?.didTapPrimaryAction()
    router.pop()
  }

  func secondaryAction() {
    router.close()
  }

  // MARK: Private

  private let error: Error
  private let router: EIDRequestInternalRoutes

}
