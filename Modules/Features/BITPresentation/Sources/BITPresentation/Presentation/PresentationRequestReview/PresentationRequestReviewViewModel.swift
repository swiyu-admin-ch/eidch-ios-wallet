import BITActivity
import BITAnalytics
import BITAppAuth
import BITCore
import BITCredential
import BITCredentialShared
import BITOpenID
import Combine
import Factory
import Foundation

// MARK: - PresentationRequestReviewViewModel

@MainActor
public class PresentationRequestReviewViewModel: ObservableObject {

  // MARK: Lifecycle

  init(context: PresentationRequestContext, router: PresentationInternalRoutes) {
    self.context = context
    self.router = router

    guard let credential = context.selectedCredential else {
      fatalError("No selected credential")
    }
    self.credential = credential
  }

  // MARK: Internal

  enum Event {
    case submit(PresentationRequestReviewState.Result, Bool)
    case deny
    case login
  }

  @Published private(set) var state = PresentationRequestReviewState.loading
  @Published var isUnknownVerifierAlertShown = false
  @Published var isSessionTimeoutPresented = false

  private(set) var denyTask: Task<Void, Error>?

  func send(_ event: Event) async {
    switch event {
    case .deny:
      await deny()
    case .submit(let result, let force):
      await submit(result, force: force)
    case .login:
      router.login(animated: true)
    }
  }

  func updateCredential(with colorScheme: String) {
    switch state {
    case .loading:
      let viewState = PresentationRequestReviewState.Result(credential: credential, verifierDisplay: verifierDisplay, colorScheme: colorScheme)
      state = .result(viewState)
    case .result(let viewState):
      let credential = VerifiableCredentialViewModel(credential: viewState.credential.credential, colorScheme: colorScheme)
      state = .result(viewState.changing(\.credential, to: credential))
    case .processing(let viewState):
      let credential = VerifiableCredentialViewModel(credential: viewState.credential.credential, colorScheme: colorScheme)
      state = .processing(viewState.changing(\.credential, to: credential))
    }
  }

  // MARK: Private

  private let credential: CompatibleCredential

  private var context: PresentationRequestContext

  private let router: PresentationInternalRoutes
  @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @Injected(\.submitPresentationUseCase) private var submitPresentationUseCase: SubmitPresentationUseCaseProtocol
  @Injected(\.declinePresentationUseCase) private var declinePresentationUseCase: DeclinePresentationUseCaseProtocol
  @Injected(\.preferredUserLanguageCodes) private var preferredUserLanguageCodes: [UserLanguageCode]
  @Injected(\.loadingMessageDelay) private var loadingMessageDelay: Double

  private var verifierDisplay: VerifierDisplay {
    context.getPreferredVerifierDisplay(considering: preferredUserLanguageCodes)
  }

  private func submit(_ result: PresentationRequestReviewState.Result, force: Bool = false) async {
    if force || context.trustInformation.identity != .unknown {
      let viewState = PresentationRequestReviewState.Processing(result: result)
      state = .processing(viewState)
      startDelayedLoadingMessageTask()
      do {
        try await submitPresentationUseCase.execute(context: context)
        router.presentationResultState(with: .success(claims: credential.requestedClusteredClaims.flatMap(\.claims)), context: context)
      } catch {
        handleSubmitError(error, processing: viewState)
      }
    } else {
      isUnknownVerifierAlertShown = true
    }
  }

  private func startDelayedLoadingMessageTask() {
    Timer.scheduledTimer(withTimeInterval: loadingMessageDelay, repeats: false, block: { _ in
      Task { @MainActor [weak self] in
        guard let self else { return }
        if case .processing(let viewModel) = state {
          let viewModel = viewModel.changing(\.isMessagePresented, to: true)
          state = .processing(viewModel)
        }
      }
    })
  }

  private func handleSubmitError(_ error: Error, processing: PresentationRequestReviewState.Processing) {
    analytics.log(error)
    if error as? UserSessionError == .notLoggedIn {
      isSessionTimeoutPresented = true
    } else {
      let resultState = PresentationRequestResultState(error: error, claims: credential.requestedClusteredClaims.flatMap(\.claims))
      router.presentationResultState(with: resultState, context: context)
    }
    let viewModel = PresentationRequestReviewState.Result(credential: credential, verifierDisplay: verifierDisplay, colorScheme: processing.credential.colorScheme)
    state = .result(viewModel)
  }

  private func deny() async {
    denyTask = Task.detached(priority: .background) { [weak self] in
      guard let self else { return }
      try? await declinePresentationUseCase(context: context)
    }
    router.presentationResultState(with: .deny, context: context)
  }
}

extension PresentationRequestResultState {
  init(error: Error, claims: [CredentialClaim]) {
    self = switch error as? SubmitPresentationError {
    case .invalidCredential:
      .invalidCredential(claims: claims)
    case .processClosed:
      .cancelled
    default:
      .error
    }
  }
}
