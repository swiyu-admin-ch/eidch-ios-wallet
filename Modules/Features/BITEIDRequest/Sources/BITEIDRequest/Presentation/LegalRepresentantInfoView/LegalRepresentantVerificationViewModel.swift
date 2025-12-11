import BITInvitation
import BITNavigation
import BITPresentation
import BITTheming
import Factory
import Foundation
import NavigatorUI

// MARK: - LegalRepresentantVerificationViewModel

@MainActor
class LegalRepresentantVerificationViewModel: ObservableObject, NavigationClosable, NavigationBackable {

  // MARK: Lifecycle

  init(router: EIDRequestRouterRoutes & EIDRequestInternalRoutes = Container.shared.eIDRequestRouter(), caseId: String) {
    self.router = router
    self.caseId = caseId
  }

  // MARK: Internal

  @Published var destination: EIDRequestDestinations?
  @Published var isNavigationCloseTriggered = false
  @Published var isNavigationBackTriggered = false

  func startVerification() async {
    do {
      let context = try await getLegalRepresentantPresentationRequestContextUseCase.execute(for: caseId)
      #warning("Might create an issue as the router is not linked to anything")
      try router.startPresentation(context: context, delegate: self)
    } catch EIDRequestRepository.Error.legalRepresentantNotRequired {
      await openConsentState()
    } catch {
      destination = .error(ErrorDataset(error, primaryAction: { [weak self] in
        self?.errorCallback(error)
      }))
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
      let state = try RequestCaseViewState(requestCase)

      if case .unknown = state {
        return isNavigationCloseTriggered = true
      }

      destination = .legalRepresentantConsentState(state: state)
    } catch {
      destination = .error(ErrorDataset(error, primaryAction: { [weak self] in
        self?.errorCallback(error)
      }))
    }
  }

  private func errorCallback(_ error: Error) {
    switch error {
    case CompatibleCredentialsError.compatibleCredentialNotFound,
         CompatibleCredentialsError.emptyWallet:
      destination = .introduction
    case EIDRequestRepository.Error.unknownError:
      isNavigationBackTriggered = true
    default:
      isNavigationCloseTriggered = true
    }
  }

}

// MARK: @preconcurrency PresentationFinishDelegate

extension LegalRepresentantVerificationViewModel: @preconcurrency PresentationFinishDelegate {
  func retry() {
    isNavigationBackTriggered = true
  }

  func cancel() {
    isNavigationCloseTriggered = true
  }

  func finish(with state: PresentationRequestResultState) async {
    switch state {
    case .success: await openConsentState()
    default: isNavigationCloseTriggered = true
    }
  }
}
