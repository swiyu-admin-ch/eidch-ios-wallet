import BITCore
import BITCredential
import BITCredentialShared
import Factory
import Foundation

// MARK: - CompatibleCredentialViewModel

class CompatibleCredentialViewModel: ObservableObject {

  // MARK: Lifecycle

  init(
    context: PresentationRequestContext,
    router: PresentationInternalRoutes)
  {
    self.context = context
    self.router = router
  }

  // MARK: Internal

  @Published var credentialViewModels = [VerifiableCredentialViewModel]()

  var verifierDisplay: VerifierDisplay {
    context.getPreferredVerifierDisplay(considering: preferredUserLanguageCodes)
  }

  func didSelect(credential: VerifiableCredential) {
    guard let compatibleCredential = context.compatibleCredentials.first(where: { $0.id == credential.id }) else { return }
    context.selectedCredential = compatibleCredential
    router.presentationReview(with: context)
  }

  func cancel() {
    router.delegate?.cancel()
  }

  func updateCredentialViewModels(with colorScheme: String) {
    credentialViewModels = context.compatibleCredentials.map(\.credential).map {
      VerifiableCredentialViewModel(credential: $0, colorScheme: colorScheme)
    }
  }

  // MARK: Private

  private var context: PresentationRequestContext
  private var router: PresentationInternalRoutes

  @Injected(\.preferredUserLanguageCodes) private var preferredUserLanguageCodes: [UserLanguageCode]

}
