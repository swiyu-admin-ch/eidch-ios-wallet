import BITCore
import Factory
import Foundation

@MainActor
final class DeclinePresentationViewModel: ObservableObject {

  // MARK: Lifecycle

  init(context: PresentationRequestContext, router: PresentationInternalRoutes) {
    self.context = context
    self.router = router
  }

  // MARK: Internal

  var verifierDisplay: VerifierDisplay {
    context.getPreferredVerifierDisplay(considering: preferredUserLanguageCodes)
  }

  func declineRequest() async {
    do {
      try await declinePresentationUseCase(url: context.responseUri)
      try? await Task.sleep(nanoseconds: declinePresentationRequestDelay)
      router.close()
    } catch {
      router.delegate?.retry()
    }
  }

  // MARK: Private

  private let router: PresentationInternalRoutes
  private let context: PresentationRequestContext

  @Injected(\.declinePresentationRequestDelay) private var declinePresentationRequestDelay
  @Injected(\.preferredUserLanguageCodes) private var preferredUserLanguageCodes: [UserLanguageCode]
  @Injected(\.declinePresentationUseCase) private var declinePresentationUseCase: DeclinePresentationUseCaseProtocol
}
