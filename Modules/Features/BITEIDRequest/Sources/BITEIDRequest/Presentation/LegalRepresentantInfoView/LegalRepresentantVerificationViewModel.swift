import BITInvitation
import BITPresentation
import Factory
import Foundation

// MARK: - LegalRepresentantVerificationViewModel

@MainActor
class LegalRepresentantVerificationViewModel {

  // MARK: Lifecycle

  init(router: EIDRequestRouterRoutes & EIDRequestInternalRoutes = Container.shared.eIDRequestRouter(), caseId: String) {
    self.router = router
    self.caseId = caseId
  }

  // MARK: Internal

  func startVerification() async {
    do {
      let context = try await getLegalRepresentantPresentationRequestContextUseCase.execute(for: caseId)
      try router.startPresentation(context: context, delegate: self)
    } catch EIDRequestRepository.Error.legalRepresentantNotRequired {
      await openConsentState()
    } catch {
      router.eIDRequestError(error: error, delegate: self)
    }
  }

  // MARK: Private

  private let caseId: String
  private let router: EIDRequestRouterRoutes & EIDRequestInternalRoutes

  @Injected(\.getLegalRepresentantPresentationRequestContextUseCase) private var getLegalRepresentantPresentationRequestContextUseCase
  @Injected(\.updateEIDRequestCaseStatusUseCase) private var updateEIDRequestCaseStatusUseCase

  private func openConsentState() async {
    do {
      let requestCase = try await updateEIDRequestCaseStatusUseCase.execute(for: caseId)
      let viewState = try RequestCaseViewState(requestCase)

      if case .unknown = viewState {
        return router.close()
      }

      router.legalRepresentantConsentState(viewState)
    } catch {
      router.eIDRequestError(error: error, delegate: self)
    }
  }

}


extension LegalRepresentantVerificationViewModel: @preconcurrency EIDRequestErrorDelegate {
  func primaryAction(error: Error) {
    switch error {
    case CompatibleCredentialsError.compatibleCredentialNotFound,
         CompatibleCredentialsError.emptyWallet:
      router.legalRepresentantEIDRequest()
    case EIDRequestRepository.Error.unknownError:
      router.pop()
    default:
      router.close()
    }
  }

  func close() {
    router.close()
  }
}

// MARK: @preconcurrency PresentationFinishDelegate

extension LegalRepresentantVerificationViewModel: @preconcurrency PresentationFinishDelegate {
  func retry() {
    router.pop()
  }

  func cancel() {
    router.close()
  }

  func finish(with state: PresentationRequestResultState) async {
    switch state {
    case .success: await openConsentState()
    default: router.close()
    }
  }
}
