import BITAnalytics
import BITCore
import BITCredential
import BITOpenID
import Combine
import Factory
import Foundation

// MARK: - PresentationRequestReviewViewModel

/// `important`: The implementation supports and takes only the first input descriptor given by the context
///
/// The support of multiple input descriptors has to be defined.
@MainActor
public class PresentationRequestReviewViewModel: ObservableObject {

  // MARK: Lifecycle

  init(
    context: PresentationRequestContext,
    router: PresentationInternalRoutes)
  {
    self.context = context
    self.router = router

    guard
      let inputDescriptor = context.requestObject.presentationDefinition.inputDescriptors.first,
      let credential = context.selectedCredentials[inputDescriptor.id] else
    {
      fatalError("Credential for input descriptor not found")
    }
    self.credential = credential
  }

  // MARK: Internal

  enum ViewState: Equatable {
    case result
    case loading
  }

  @Published var state = ViewState.result
  @Published var showLoadingMessage = false
  @Published var credentialViewModel: CredentialViewModel?

  let credential: CompatibleCredential
  var denyTask: Task<Void, Error>?

  var verifierDisplay: VerifierDisplay {
    context.getVerifierDisplay(considering: preferredUserLanguageCodes)
  }

  func submit() async {
    state = .loading
    startDelayedLoadingMessageTask()
    do {
      try await submitPresentationUseCase.execute(context: context)
      router.presentationResultState(with: .success(claims: credential.requestedClusteredClaims.flatMap(\.claims)), context: context)
    } catch {
      handleSubmitError(error)
    }
  }

  func deny() async {
    denyTask = Task.detached(priority: .background) { [weak self] in
      guard let self else { return }
      try? await declinePresentationUseCase.execute(requestObject: context.requestObject)
    }
    router.presentationResultState(with: .deny, context: context)
  }

  func updateCredentialViewModel(with colorScheme: String) {
    let display = getCredentialDisplayUseCase.execute(for: credential.credential.displays, colorScheme: colorScheme)
    credentialViewModel = CredentialViewModel(credential: credential.credential, credentialDisplay: display)
  }

  // MARK: Private

  private var context: PresentationRequestContext

  private let router: PresentationInternalRoutes
  @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @Injected(\.submitPresentationUseCase) private var submitPresentationUseCase: SubmitPresentationUseCaseProtocol
  @Injected(\.declinePresentationUseCase) private var declinePresentationUseCase: DeclinePresentationUseCaseProtocol
  @Injected(\.preferredUserLanguageCodes) private var preferredUserLanguageCodes: [UserLanguageCode]
  @Injected(\.getCredentialDisplayUseCase) private var getCredentialDisplayUseCase: GetCredentialDisplayUseCaseProtocol
  @Injected(\.loadingMessageDelay) private var loadingMessageDelay: Double

  private func startDelayedLoadingMessageTask() {
    Timer.scheduledTimer(withTimeInterval: loadingMessageDelay, repeats: false, block: { _ in
      Task { @MainActor [weak self] in
        guard let self else { return }
        showLoadingMessage = state == .loading
      }
    })
  }

  private func handleSubmitError(_ error: Error) {
    showLoadingMessage = false
    analytics.log(error)
    if let presentationError = error as? SubmitPresentationError {
      switch presentationError {
      case .invalidCredential:
        router.presentationResultState(with: .invalidCredential(claims: credential.requestedClusteredClaims.flatMap(\.claims)), context: context)
      case .processClosed:
        router.presentationResultState(with: .cancelled, context: context)
      default:
        router.presentationResultState(with: .error, context: context)
      }
    } else {
      router.presentationResultState(with: .error, context: context)
    }
    state = .result
  }

}
