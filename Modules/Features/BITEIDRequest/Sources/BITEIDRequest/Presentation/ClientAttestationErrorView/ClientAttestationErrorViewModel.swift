import BITL10n
import SwiftUI

class ClientAttestationErrorViewModel: ObservableObject {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    self.router = router
  }

  // MARK: Internal

  func openHelp() {
    guard let url = URL(string: L10n.tkEidRequestClientAttestationErrorHelpLink) else {
      return
    }

    router.openExternalLink(url: url)
  }

  func primaryAction() {
    guard let url = URL(string: L10n.tkGlobalStoreLink) else {
      return
    }

    router.openExternalLink(url: url)
  }

  func secondaryAction() {
    router.close()
  }

  // MARK: Private

  private let router: EIDRequestInternalRoutes
}
