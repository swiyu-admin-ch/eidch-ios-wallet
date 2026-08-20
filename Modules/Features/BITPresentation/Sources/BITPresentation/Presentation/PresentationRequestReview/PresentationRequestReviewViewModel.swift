import BITActivity
import BITAnalytics
import BITCore
import BITCredential
import BITCredentialShared
import BITL10n
import BITNetworking
import BITNonCompliance
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
    case onAppear
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
    case .onAppear:
      await validateProtectedClaims()
    }
  }

  func updateCredential(with colorScheme: String) {
    switch state {
    case .loading:
      let viewState = PresentationRequestReviewState.Result(
        credential: credential,
        verifierDisplay: verifierDisplay,
        colorScheme: colorScheme,
        hasVerifiedQuery: context.hasVerifiedQuery)
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
  @ObservationIgnored @Injected(\.validateVerificationAuthorizationTrustStatementUseCase) private var validateVerificationAuthorizationTrustStatementUseCase

  private var reviewAlert: PresentationRequestReviewAlert? {
    if case .notCompliant = context.actorCompliance {
      return .nonCompliantActor
    }

    if !context.hasVerifiedQuery {
      return .unregisteredRequest
    }

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

  private func validateProtectedClaims() async {
    do {
      try await validateVerificationAuthorizationTrustStatementUseCase(requestObject: context.requestObject, requestedClaims: credential.presentingPaths)
    } catch let error as ValidateVerificationAuthorizationTrustStatementUseCaseError {
      switch error {
      case .unauthorizedVerification(let presentationResponse):
        destination = .error(
          .governanceError(
            rawErrorCode: GovernanceError.unauthorizedVerification.rawValue,
            errorDescription: L10n.tkPresentErrorUnauthorizedVerificationSecondary),
          presentationResponse)
      }
    } catch is PresentationResponseValidationError {
      destination = .error(.invalidRedirectUri, nil)
    } catch {
      destination = .resultState(.error, context)
    }
  }

  private func submit(_ result: PresentationRequestReviewState.Result, force: Bool = false) async {
    alert = nil

    if !force, let reviewAlert {
      alert = reviewAlert
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
          case .success(let presentationResponse):
            destination = .resultState(.dataTransmitted(presentationResponse), context)
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
    if error is PresentationResponseValidationError {
      destination = .error(.invalidRedirectUri, nil)
    } else if let networkError = error as? NetworkError {
      switch networkError.status {
      case .hostnameNotFound,
           .noConnection,
           .timeout,
           .unknown:
        destination = .resultState(.error, context)
      default:
        destination = .resultState(.dataTransmitted(nil), context)
      }
    } else {
      destination = .resultState(.error, context)
    }
    let viewModel = PresentationRequestReviewState.Result(
      credential: credential,
      verifierDisplay: verifierDisplay,
      colorScheme: processing.credential.colorScheme,
      hasVerifiedQuery: context.hasVerifiedQuery)
    state = .result(viewModel)
  }

  @MainActor
  private func deny() async {
    do {
      let presentationResponse = try await declinePresentationUseCase(context: context)
      destination = .resultState(.deny(presentationResponse), context)
    } catch is PresentationResponseValidationError {
      destination = .error(.invalidRedirectUri, nil)
    } catch {
      destination = .resultState(.deny(nil), context)
    }
  }
}
