import Spyable
import SwiftUI

class AVIntroSelfieVideoViewModel {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    self.router = router
  }

  // MARK: Internal

  func primaryAction() {
    router.recordSelfie()
  }

  func close() {
    router.close()
  }

  // MARK: Private

  private let router: EIDRequestInternalRoutes

}
