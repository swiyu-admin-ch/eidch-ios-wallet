import Spyable
import SwiftUI

// MARK: - AttestationErrorDelegate

@Spyable
protocol AttestationErrorDelegate: AnyObject {
  func didTapPrimaryAction()
}

// MARK: - AttestationErrorViewModel

class AttestationErrorViewModel: ObservableObject {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes, delegate: AttestationErrorDelegate) {
    self.router = router
    self.delegate = delegate
  }

  // MARK: Internal

  weak var delegate: AttestationErrorDelegate?

  func primaryAction() {
    delegate?.didTapPrimaryAction()
    router.pop()
  }

  func secondaryAction() {
    router.close()
  }

  // MARK: Private

  private let router: EIDRequestInternalRoutes

}
