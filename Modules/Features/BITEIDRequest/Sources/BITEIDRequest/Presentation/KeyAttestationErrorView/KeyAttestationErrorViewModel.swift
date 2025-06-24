import BITL10n
import SwiftUI

class KeyAttestationErrorViewModel: ObservableObject {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    self.router = router
  }

  // MARK: Internal

  func openHelp() {
    guard let url = URL(string: L10n.tkEidRequestKeyAttestationErrorHelpLink) else {
      return
    }

    router.openExternalLink(url: url)
  }

  func primaryAction() {
    router.close()
  }

  // MARK: Private

  private let router: EIDRequestInternalRoutes
}
