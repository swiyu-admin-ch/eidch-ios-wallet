import BITL10n
import BITTheming

extension ToastType {
  var message: String {
    switch self {
    case .error:
      L10n.tkErrorGenericPrimary
    case .success:
      L10n.tkSettingsActivityHistoryDeletionSuccessMessage
    }
  }
}
