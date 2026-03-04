import BITAnalytics
import BITAppAuth
import BITCore
import BITCredential
import BITCredentialShared
import BITEIDRequest
import BITEIDRequestShared
import BITInvitation
import BITL10n
import Combine
import Factory
import Foundation
import SwiftUI

// MARK: - HomeViewModel

@MainActor
class HomeViewModel: ObservableObject {

  // MARK: Lifecycle

  init(router: HomeRouterRoutes) {
    self.router = router
  }

  // MARK: Internal

  enum State {
    case results
    case error(_ error: Error)
    case empty
  }

  @Published var state = State.results
  @Published var requestCases = [RequestCaseViewState]()
  @Published var credentials = [any CredentialViewModelProtocol]()
  @Published var isToastPresented = false
  @Published private(set) var toastMessage: String?

  @Injected(\.isEIDRequestFeatureEnabled) var isEIDRequestFeatureEnabled: Bool

  func onAppear() async {
    if isEIDRequestFeatureEnabled, isEIDRequestAfterOnboardingEnabledUseCase.execute() {
      router.eIDRequest()
      enableEIDRequestAfterOnboardingUseCase.execute(false)
    }

    if isUserLoggedInUseCase.execute() {
      await fetchData()
    }
  }

  func refresh() async {
    await fetchData()
  }

  // MARK: Private

  private var colorScheme = String()
  private let router: HomeRouterRoutes

  @Injected(\.getCredentialListUseCase) private var getCredentialListUseCase: GetCredentialListUseCaseProtocol
  @Injected(\.isUserLoggedInUseCase) private var isUserLoggedInUseCase: IsUserLoggedInUseCaseProtocol
  @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @Injected(\.isEIDRequestAfterOnboardingEnabledUseCase) private var isEIDRequestAfterOnboardingEnabledUseCase: IsEIDRequestAfterOnboardingEnabledUseCaseProtocol
  @Injected(\.enableEIDRequestAfterOnboardingUseCase) private var enableEIDRequestAfterOnboardingUseCase: EnableEIDRequestAfterOnboardingUseCaseProtocol
  @Injected(\.getEIDRequestCaseListUseCase) private var getEIDRequestCaseListUseCase: GetEIDRequestCaseListUseCaseProtocol
  @Injected(\.updateEIDRequestCaseStatusUseCase) private var updateEIDRequestCaseStatusUseCase: UpdateEIDRequestCaseStatusUseCaseProtocol
  @Injected(\.refreshCredentialsUseCase) private var refreshCredentialsUseCase: RefreshCredentialsUseCaseProtocol

  private func fetchData() async {
    await withTaskGroup(of: Void.self) { group in
      group.addTask { await self.fetchCredentials() }
      group.addTask { await self.getEIDRequestCases() }

      await group.waitForAll()
    }
  }

  @MainActor
  private func setState(_ newState: State) {
    withAnimation {
      self.state = newState
    }
  }
}

// MARK: - Navigation

extension HomeViewModel {

  // MARK: Internal

  func openScanner() {
    router.invitation(delegate: self)
  }

  func openSettings() {
    router.settings()
  }

  func openHelp() {
    guard let url = URL(string: L10n.tkSettingsGeneralHelpLinkValue) else { return }
    router.openExternalLink(url: url)
  }

  func openCredential(_ credentialViewModel: any CredentialViewModelProtocol) {
    switch credentialViewModel.credential {
    case let verifiableCredential as VerifiableCredential:
      openVerifiableCredential(verifiableCredential)
    case let deferredCredential as DeferredCredential:
      openDeferredCredential(deferredCredential)
    default: return
    }
  }

  func openBetaId() {
    router.betaId()
  }

  func openEIDRequest() {
    router.eIDRequest()
  }

  // MARK: Private

  private func openVerifiableCredential(_ verifiableCredential: VerifiableCredential) {
    switch verifiableCredential.progressionState {
    case .accepted:
      router.credentialDetail(verifiableCredential, delegate: self)
    case .unaccepted:
      router.credentialOffer(credential: verifiableCredential, delegate: self)
    }
  }

  private func openDeferredCredential(_ deferredCredential: DeferredCredential) {
    router.credentialDetail(deferredCredential, delegate: self)
  }

}

// MARK: - Credentials

extension HomeViewModel {

  // MARK: Internal

  func updateCredentialViewModels(with colorScheme: String) {
    self.colorScheme = colorScheme
    credentials = computeViewModels(for: credentials.compactMap { $0.credential as? CredentialProtocol }, with: colorScheme)
  }

  // MARK: Private

  private func fetchCredentials() async {
    do {
      let allCredentials = try await getCredentialListUseCase.execute()
      updateView(with: allCredentials)

      await refreshCredentials()
    } catch {
      analytics.log(error)

      if credentials.isEmpty {
        setState(.error(error))
      }
    }
  }

  private func refreshCredentials() async {
    do {
      let credentials = try await refreshCredentialsUseCase()
      updateView(with: credentials)
    } catch {
      analytics.log(error)
    }
  }

  private func updateView(with credentials: [any CredentialProtocol], colorScheme: String = "") {
    setState(credentials.isEmpty ? .empty : .results)

    withAnimation {
      self.credentials = computeViewModels(for: credentials, with: colorScheme)
    }
  }

  private func computeViewModels(for credentials: [any CredentialProtocol], with colorScheme: String = String()) -> [any CredentialViewModelProtocol] {
    credentials.compactMap {
      if let verifiableCredential = $0 as? VerifiableCredential {
        return VerifiableCredentialViewModel(credential: verifiableCredential, colorScheme: colorScheme)
      }

      if let deferredCredential = $0 as? DeferredCredential {
        return DeferredCredentialViewModel(credential: deferredCredential, colorScheme: colorScheme)
      }

      return nil
    }
  }

}


extension HomeViewModel {

  @MainActor
  private func getEIDRequestCases() async {
    do {
      let temporaryRequestCases = try await getEIDRequestCaseListUseCase.execute()
      updateView(with: temporaryRequestCases)

      await refreshRequestCases()
    } catch {}
  }

  @MainActor
  private func refreshRequestCases() async {
    do {
      try await updateEIDRequestCaseStatusUseCase.execute(requestCases.map(\.id))
      let requestCases = try await getEIDRequestCaseListUseCase.execute()
      updateView(with: requestCases)
    } catch {
      // Request cases list is not updated if error
    }
  }

  private func updateView(with requestCases: [EIDRequestCase]) {
    withAnimation {
      self.requestCases = requestCases
        .compactMap { try? RequestCaseViewState($0, delegate: self) }
    }
  }

}

// MARK: RequestCaseViewStateDelegate

extension HomeViewModel: RequestCaseViewStateDelegate {
  func didDeleteRequestCase() {
    Task {
      await getEIDRequestCases()
    }
  }

  func didStartAutoVerification(caseId: String) {
    router.autoVerification(caseId: caseId)
  }

  func didUpdateRequestCaseState() {
    Task {
      await refreshRequestCases()
    }
  }

  func didTapObtainConsent(caseId: String) {
    router.obtainConsent(caseId: caseId)
  }

  func didOpenExternalLink(url: URL) {
    router.openExternalLink(url: url)
  }

  func didTapWalletPairing(caseId: String) {
    router.walletPairing(caseId: caseId)
  }

  func didTapIdentityCheck(caseId: String) {
    router.identityCheck(caseId: caseId)
  }
}

// MARK: @preconcurrency InvitationDelegate

extension HomeViewModel: @preconcurrency InvitationDelegate {

  func didSaveCredential() {
    toastMessage = L10n.tkHomeNotificationCredentialAccepted
    isToastPresented = true
  }

  func didDeclineCredential() {
    toastMessage = L10n.tkHomeNotificationCredentialDeclined
    isToastPresented = true
  }
}

extension HomeViewModel {
  func clearToast() {
    isToastPresented = false
    toastMessage = nil
  }
}

// MARK: @MainActor CredentialDetailDelegate

extension HomeViewModel: @MainActor CredentialDetailDelegate {
  func onCredentialDeleted() {
    toastMessage = L10n.tkHomeNotificationCredentialDeleted
    isToastPresented = true
  }
}
