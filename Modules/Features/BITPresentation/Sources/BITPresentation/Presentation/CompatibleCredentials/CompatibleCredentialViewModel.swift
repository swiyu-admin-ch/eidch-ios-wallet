import BITCredential
import BITCredentialShared
import Factory
import Foundation

// MARK: - CompatibleCredentialViewModel

public class CompatibleCredentialViewModel: ObservableObject {

  // MARK: Lifecycle

  public init(
    context: PresentationRequestContext,
    inputDescriptorId: String,
    compatibleCredentials: [CompatibleCredential],
    router: PresentationRouterRoutes)
  {
    self.context = context
    self.inputDescriptorId = inputDescriptorId
    self.compatibleCredentials = compatibleCredentials
    self.router = router

    verifierDisplay = getVerifierDisplayUseCase.execute(for: context.requestObject.clientMetadata, trustStatement: context.trustStatement)
  }

  // MARK: Internal

  @Published var credentialViewModels: [CredentialViewModel] = []

  var verifierDisplay: VerifierDisplay?

  func didSelect(credential: Credential) {
    guard let compatibleCredential = compatibleCredentials.first(where: { $0.id == credential.id }) else { return }
    context.selectedCredentials[inputDescriptorId] = compatibleCredential
    router.presentationReview(with: context)
  }

  func close() {
    router.close()
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
  private var router: PresentationRouterRoutes
  @Injected(\.getVerifierDisplayUseCase) private var getVerifierDisplayUseCase: GetVerifierDisplayUseCaseProtocol
  @Injected(\.getCredentialDisplayUseCase) private var getCredentialDisplayUseCase: GetCredentialDisplayUseCaseProtocol

}
