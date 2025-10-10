import BITCore
import Factory
import Foundation

// MARK: - PresentationRequestResultStateViewModel

@MainActor
public class PresentationRequestResultStateViewModel: ObservableObject {

  // MARK: Lifecycle

  init(
    state: PresentationRequestResultState,
    context: PresentationRequestContext,
    router: PresentationInternalRoutes)
  {
    self.state = state
    self.context = context
    self.router = router
  }

  // MARK: Internal

  let state: PresentationRequestResultState

  var verifierDisplay: VerifierDisplay {
    context.getVerifierDisplay(considering: preferredUserLanguageCodes)
  }

  func finish() async {
    await router.delegate?.finish(with: state)
  }

  func retry() {
    router.delegate?.retry()
  }

  // MARK: Private

  private let router: PresentationInternalRoutes
  private let context: PresentationRequestContext
  @Injected(\.preferredUserLanguageCodes) private var preferredUserLanguageCodes: [UserLanguageCode]

}
