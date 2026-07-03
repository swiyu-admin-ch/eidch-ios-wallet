import BITCore
import BITNavigation
import Factory
import Foundation
import NavigatorUI

@MainActor
@Observable
final class DeclinePresentationViewModel {

  // MARK: Lifecycle

  init(context: PresentationRequestContext) {
    self.context = context
  }

  // MARK: Internal

  var verifierDisplay: VerifierDisplay {
    context.getPreferredVerifierDisplay(considering: preferredUserLanguageCodes)
  }

  func declineRequest(_ navigator: Navigator) async {
    do {
      try await declinePresentationUseCase(context: context)
      try? await Task.sleep(nanoseconds: declinePresentationRequestDelay)
      navigator.returnToHomeSafely()
    } catch {
      navigator.pop()
    }
  }

  // MARK: Private

  private let context: PresentationRequestContext

  @ObservationIgnored @Injected(\.declinePresentationRequestDelay) private var declinePresentationRequestDelay
  @ObservationIgnored @Injected(\.preferredUserLanguageCodes) private var preferredUserLanguageCodes: [UserLanguageCode]
  @ObservationIgnored @Injected(\.declinePresentationUseCase) private var declinePresentationUseCase: DeclinePresentationUseCaseProtocol
}
