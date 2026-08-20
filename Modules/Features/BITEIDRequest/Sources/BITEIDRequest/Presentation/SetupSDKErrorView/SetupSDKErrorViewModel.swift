import BITL10n
import BITNavigation
import DeviceCheck
import Spyable
import SwiftUI

// MARK: - SetupSDKErrorViewModel

@Observable

class SetupSDKErrorViewModel: NavigationBackable {

  // MARK: Lifecycle

  init(error: ErrorWrapper, callback: @escaping (Void) -> Void) {
    self.error = error.error
    self.callback = callback
  }

  // MARK: Internal

  var isNavigationBackTriggered = false

  var primaryText: String {
    switch error {
    case SIDRepository.Error.insufficientKeyStorageResistance:
      L10n.tkEidRequestClientAttestationInsufficientKeyStorageTitle
    case DCError.serverUnavailable:
      L10n.tkEidRequestClientAttestationDeviceCheckTimeoutTitle
    case is DCError:
      L10n.tkEidRequestClientAttestationDeviceCheckErrorTitle
    case ValidateDeviceSecurityRequirementsUseCaseError.networkError:
      L10n.tkEidRequestClientAttestationServiceErrorTitle
    default:
      L10n.tkEidRequestAttestationUnknownErrorPrimary
    }
  }

  var secondaryText: String {
    switch error {
    case SIDRepository.Error.insufficientKeyStorageResistance:
      L10n.tkEidRequestClientAttestationInsufficientKeyStorageBody
    case DCError.serverUnavailable:
      L10n.tkEidRequestClientAttestationDeviceCheckTimeoutBody
    case is DCError:
      L10n.tkEidRequestClientAttestationDeviceCheckErrorBody
    case ValidateDeviceSecurityRequirementsUseCaseError.networkError:
      L10n.tkEidRequestClientAttestationServiceErrorBody
    default:
      L10n.tkEidRequestAttestationUnknownErrorSecondary
    }
  }

  var isRetryEnabled: Bool {
    switch error {
    case DCError.serverUnavailable,
         SIDRepository.Error.unknownError:
      true
    case is DCError,
         SIDRepository.Error.insufficientKeyStorageResistance:
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
