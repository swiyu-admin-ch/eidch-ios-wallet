import BITCore
import BITCredential
import BITCredentialShared
import Factory
import Foundation

// MARK: - CompatibleCredentialViewModel

@Observable
class CompatibleCredentialViewModel {

  // MARK: Lifecycle

  init(context: PresentationRequestContext) {
    self.context = context
  }

  // MARK: Internal

  var destination: PresentationDestinations?
  var credentialViewModels = [VerifiableCredentialViewModel]()

  var verifierDisplay: VerifierDisplay {
    context.getPreferredVerifierDisplay(considering: preferredUserLanguageCodes)
  }

  func didSelect(credential: VerifiableCredential) {
    guard let compatibleCredential = context.compatibleCredentials.first(where: { $0.id == credential.id }) else { return }
    context.selectedCredential = compatibleCredential
    destination = .requestReview(context)
  }

  func updateCredentialViewModels(with colorScheme: String) {
    credentialViewModels = context.compatibleCredentials.map(\.credential).map {
      VerifiableCredentialViewModel(credential: $0, colorScheme: colorScheme)
    }
  }

  // MARK: Private

  private var context: PresentationRequestContext

  @ObservationIgnored @Injected(\.preferredUserLanguageCodes) private var preferredUserLanguageCodes: [UserLanguageCode]

}
