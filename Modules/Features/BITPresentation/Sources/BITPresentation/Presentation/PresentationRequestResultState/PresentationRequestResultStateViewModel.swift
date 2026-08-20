import BITCore
import BITL10n
import BITNavigation
import Factory
import Foundation
import UIKit

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

  var hasRedirectUri: Bool {
    state.presentationResponse?.redirectUri != nil
  }

  var redirectInformationText: String? {
    guard hasRedirectUri else { return nil }
    guard case .dataTransmitted = state else {
      return L10n.tkPresentRedirectInformationBody(actorName)
    }
    return nil
  }

  var dataTransmittedBody: String {
    if hasRedirectUri {
      L10n.tkPresentResultDataTransmittedRedirectBody(actorName)
    } else {
      L10n.tkPresentResultDataTransmittedBody
    }
  }

  var finishButtonText: String {
    if hasRedirectUri {
      L10n.tkPresentRedirectInformationButton(actorName)
    } else {
      L10n.tkGlobalFinish
    }
  }

  var verifierDisplay: VerifierDisplay {
    context.getPreferredVerifierDisplay(considering: preferredUserLanguageCodes)
  }

  func retry() {
    isNavigationBackTriggered = true
  }

  func openRedirectUri(_ completion: @escaping () -> Void) {
    guard let redirectUri = state.presentationResponse?.redirectUri else { return }
    UIApplication.shared.open(redirectUri) { _ in
      completion()
    }
  }

  // MARK: Private

  private let context: PresentationRequestContext

  @ObservationIgnored @Injected(\.preferredUserLanguageCodes) private var preferredUserLanguageCodes: [UserLanguageCode]

  private var actorName: String {
    verifierDisplay.name ?? L10n.tkPresentVerifierNameUnknown
  }

}
