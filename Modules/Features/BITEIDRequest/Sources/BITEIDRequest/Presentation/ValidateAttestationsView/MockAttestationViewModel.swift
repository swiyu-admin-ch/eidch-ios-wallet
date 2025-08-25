#if DEBUG
import Foundation
import SwiftUI

class MockValidateAttestationsViewModel: ValidateAttestationsViewModelProtocol {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    self.router = router
  }

  // MARK: Internal

  @MainActor
  func fetchAttestations() async {
    router.legalRepresentant()
  }

  // MARK: Private

  private let router: EIDRequestInternalRoutes

}
#endif
