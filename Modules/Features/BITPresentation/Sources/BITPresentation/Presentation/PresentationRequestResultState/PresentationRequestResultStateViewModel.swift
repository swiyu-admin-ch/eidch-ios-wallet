import BITCore
import BITNavigation
import Factory
import Foundation

@MainActor
@Observable
class PresentationRequestResultStateViewModel: NavigationBackable {

  // MARK: Lifecycle

  init(state: PresentationRequestResultState, context: PresentationRequestContext) {
    self.state = state
    self.context = context
  }

  // MARK: Internal

  let state: PresentationRequestResultState

  var isNavigationBackTriggered = false

  var verifierDisplay: VerifierDisplay {
    context.getPreferredVerifierDisplay(considering: preferredUserLanguageCodes)
  }

  func retry() {
    isNavigationBackTriggered = true
  }

  // MARK: Private

  private let context: PresentationRequestContext

  @ObservationIgnored @Injected(\.preferredUserLanguageCodes) private var preferredUserLanguageCodes: [UserLanguageCode]
}
