import BITActivity
import BITAnalytics
import BITCore
import BITCredential
import BITCredentialShared
import BITNetworking
import BITOpenID
import Factory
import Foundation

// MARK: - PresentationRequestReviewViewModel

@MainActor
@Observable
public class PresentationRequestReviewViewModel {

  // MARK: Lifecycle

  init(context: PresentationRequestContext) {
    self.context = context

    guard let credential = context.selectedCredential else {
      fatalError("No selected credential")
    }
    self.credential = credential
  }

  // MARK: Internal

  enum Event {
    case submit(PresentationRequestReviewState.Result, Bool)
    case deny
  }

  private(set) var state = PresentationRequestReviewState.loading
  var alert: PresentationRequestReviewAlert?
  var destination: PresentationDestinations?

  private(set) var denyTask: Task<Void, Error>?

  func send(_ event: Event) async {
    switch event {
    case .deny:
      await deny()
    case .submit(let result, let force):
      await submit(result, force: force)
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

  @ObservationIgnored @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @ObservationIgnored @Injected(\.submitPresentationUseCase) private var submitPresentationUseCase: SubmitPresentationUseCaseProtocol
  @ObservationIgnored @Injected(\.declinePresentationUseCase) private var declinePresentationUseCase: DeclinePresentationUseCaseProtocol
  @ObservationIgnored @Injected(\.preferredUserLanguageCodes) private var preferredUserLanguageCodes: [UserLanguageCode]
  @ObservationIgnored @Injected(\.loadingMessageDelay) private var loadingMessageDelay: Double
  @ObservationIgnored @Injected(\.selectCredentialBundleItemUseCase) private var selectCredentialBundleItemUseCase: SelectCredentialBundleItemUseCaseProtocol

  private var credentialStatusAlert: PresentationRequestReviewAlert? {
    guard let bundleItem = try? selectCredentialBundleItemUseCase(credential.credential) else { return nil }
    switch bundleItem.status {
    case .businessExpired:
      return .businessExpiredCredential
    case .suspended:
      return .suspendedCredential
    default:
      return nil
    }
  }

  private var verifierDisplay: VerifierDisplay {
    context.getPreferredVerifierDisplay(considering: preferredUserLanguageCodes)
  }

  private func submit(_ result: PresentationRequestReviewState.Result, force: Bool = false) async {
    alert = nil

    if !force, let credentialStatusAlert {
      alert = credentialStatusAlert
      return
    }

    if force || context.trustInformation.identity != .unknown {
      let viewState = PresentationRequestReviewState.Processing(result: result)
      state = .processing(viewState)
      startDelayedLoadingMessageTask()
      do {
        for try await event in submitPresentationUseCase.execute(context: context) {
          switch event {
          case .progress(let progress):
            guard case .processing(let currentState) = state else { continue }
            state = .processing(currentState.changing(\.progress, to: progress))
          case .success:
            destination = .resultState(.dataTransmitted, context)
            return
          }
        }
      } catch {
        handleSubmitError(error, processing: viewState)
      }
    } else {
      alert = .unknownVerifier
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
    if let networkError = error as? NetworkError {
      switch networkError.status {
      case .hostnameNotFound,
           .noConnection,
           .timeout,
           .unknown:
        destination = .resultState(.error, context)
      default:
        destination = .resultState(.dataTransmitted, context)
      }
    } else {
      destination = .resultState(.error, context)
    }
    let viewModel = PresentationRequestReviewState.Result(credential: credential, verifierDisplay: verifierDisplay, colorScheme: processing.credential.colorScheme)
    state = .result(viewModel)
  }

  private func deny() async {
    denyTask = Task.detached(priority: .background) { [weak self] in
      guard let self else { return }
      try? await declinePresentationUseCase(context: context)
    }

    destination = .resultState(.deny, context)
  }
}
