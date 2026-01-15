import BITL10n
import BITNavigation
import DeviceCheck
import Spyable
import SwiftUI

// MARK: - ValidateAttestationsErrorViewModel

class ValidateAttestationsErrorViewModel: ObservableObject, NavigationBackable {

  // MARK: Lifecycle

  init(error: ErrorWrapper, callback: @escaping (Void) -> Void) {
    self.error = error.error
    self.callback = callback
  }

  // MARK: Internal

  @Published var isNavigationBackTriggered = false

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
    callback(Void())
    isNavigationBackTriggered = true
  }

  // MARK: Private

  private var callback: (Void) -> Void
  private let error: Error

}
