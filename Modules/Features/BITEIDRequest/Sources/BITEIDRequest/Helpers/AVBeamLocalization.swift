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

  var title: String {
    L10n.tr("Localizable", "\(textkey)_title", fallback: L10n.tkErrorGenericPrimary)
  }

  var content: String {
    L10n.tr("Localizable", "\(textkey)_content", fallback: L10n.tkErrorGenericSecondary)
  }
}
