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
    inputDescriptorId: String,
    compatibleCredentials: [CompatibleCredential],
    router: PresentationInternalRoutes)
  {
    self.context = context
    self.inputDescriptorId = inputDescriptorId
    self.compatibleCredentials = compatibleCredentials
    self.router = router
  }

  // MARK: Internal

  @Published var credentialViewModels = [CredentialViewModel]()

  var verifierDisplay: VerifierDisplay {
    context.getVerifierDisplay(considering: preferredUserLanguageCodes)
  }

  func didSelect(credential: VerifiableCredential) {
    guard let compatibleCredential = compatibleCredentials.first(where: { $0.id == credential.id }) else { return }
    context.selectedCredentials[inputDescriptorId] = compatibleCredential
    router.presentationReview(with: context)
  }

  func cancel() {
    router.delegate?.cancel()
  }

  func updateCredentialViewModels(with colorScheme: String) {
    credentialViewModels = compatibleCredentials.map(\.credential).map {
      let display = getCredentialDisplayUseCase.execute(for: $0.displays, colorScheme: colorScheme)
      return CredentialViewModel(credential: $0, credentialDisplay: display)
    }
  }

  // MARK: Private

  private let compatibleCredentials: [CompatibleCredential]
  private var inputDescriptorId: String
  private var context: PresentationRequestContext
  private var router: PresentationInternalRoutes
  @Injected(\.preferredUserLanguageCodes) private var preferredUserLanguageCodes: [UserLanguageCode]
  @Injected(\.getCredentialDisplayUseCase) private var getCredentialDisplayUseCase: GetCredentialDisplayUseCaseProtocol

}
