import BITNavigation
import Foundation
import NavigatorUI

// MARK: - UnregisteredRequestViewModel

@MainActor
@Observable
class UnregisteredRequestViewModel {

  // MARK: Lifecycle

  init(context: PresentationRequestContext) {
    self.context = context
  }

  // MARK: Internal

  var destination: PresentationDestinations?

  func proceed() {
    if context.compatibleCredentials.isEmpty {
      destination = .noCompatibleCredential(context)
    } else if context.compatibleCredentials.count > 1 {
      destination = .compatibleCredentials(context)
    } else {
      destination = .requestReview(context)
    }
  }

  func cancel(_ navigator: Navigator) {
    navigator.returnToHomeSafely()
  }

  // MARK: Private

  private let context: PresentationRequestContext
}
