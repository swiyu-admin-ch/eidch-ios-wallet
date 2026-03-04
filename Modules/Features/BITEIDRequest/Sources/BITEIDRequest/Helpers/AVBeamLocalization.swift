import BITAVWrapper
import BITL10n
import Foundation

extension AVBeamNotification {
  var localizedDescription: String {
    L10n.tr("Localizable", textkey, fallback: textkey)
  }
}

extension AVBeamError {
  var localizedDescription: String {
    L10n.tr("Localizable", textkey, fallback: textkey)
  }
}
