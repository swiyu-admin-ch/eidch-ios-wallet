import BITCore
import BITNavigation
import BITOpenID
import Factory
import Foundation
import NavigatorUI

@MainActor
@Observable
final class NoCompatibleCredentialViewModel {

  // MARK: Lifecycle

  init(context: PresentationRequestContext) {
    self.context = context
  }

  // MARK: Internal

  var destination: PresentationDestinations?

  var verifierDisplay: VerifierDisplay {
    context.getPreferredVerifierDisplay(considering: preferredUserLanguageCodes)
  }

  func declineRequest(_ navigator: Navigator) async {
    do {
      let presentationResponse = try await declinePresentationUseCase(context: context)
      try? await Task.sleep(nanoseconds: declinePresentationRequestDelay)
      guard let presentationResponse, presentationResponse.redirectUri != nil else {
        navigator.returnToHomeSafely()
        return
      }
      destination = .resultState(.deny(presentationResponse), context)
    } catch is PresentationResponseValidationError {
      destination = .error(.invalidRedirectUri, nil)
    } catch {
      navigator.returnToHomeSafely()
    }
  }

  // MARK: Private

  private let context: PresentationRequestContext

  @ObservationIgnored @Injected(\.declinePresentationRequestDelay) private var declinePresentationRequestDelay
  @ObservationIgnored @Injected(\.preferredUserLanguageCodes) private var preferredUserLanguageCodes: [UserLanguageCode]
  @ObservationIgnored @Injected(\.declinePresentationUseCase) private var declinePresentationUseCase: DeclinePresentationUseCaseProtocol
}
