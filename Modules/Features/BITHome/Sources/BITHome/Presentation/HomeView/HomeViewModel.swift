import BITAnalytics
import BITAppAuth
import BITCore
import BITCredential
import BITCredentialShared
import BITEIDRequest
import BITEIDRequestShared
import BITInvitation
import BITL10n
import BITNavigation
import BITOTP
import BITPushNotification
import BITTheming
import Factory
import SwiftUI

// MARK: - HomeViewModel

@MainActor
@Observable
final class HomeViewModel {

  // MARK: Lifecycle

  init() {
    requestCasePollingManager.delegate = self
    registerNotificationListeners()
  }

  deinit {
    notificationTasks.forEach { $0.cancel() }
  }

  // MARK: Internal

  enum State {
    case results
    case error(_ error: Error)
    case empty
  }

  var state = State.results
  var requestCases = [RequestCaseViewState]()
  var credentials = [any CredentialViewModelProtocol]()
  var toast: Toast?
  var destination: HomeDestinations?
  var externalURL: URL?

  @ObservationIgnored @Injected(\.isProximityEnabled) var isProximityEnabled: Bool

  func onAppear() async {
    if isUserLoggedInUseCase() {
      await fetchData()
    }
  }

  func refresh() async {
    await fetchData()
  }

  func didLogin() async {
    await refresh()
  }

  func stopRefresh() {
    requestCasePollingManager.stopPolling()
  }

  // MARK: Private

  private var colorScheme = String()
  @ObservationIgnored private var notificationTasks = [Task<Void, Never>]()
  @ObservationIgnored @Injected(\.getCredentialListUseCase) private var getCredentialListUseCase: GetCredentialListUseCaseProtocol
  @ObservationIgnored @Injected(\.isUserLoggedInUseCase) private var isUserLoggedInUseCase: IsUserLoggedInUseCaseProtocol
  @ObservationIgnored @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @ObservationIgnored @Injected(\.getEIDRequestCaseListUseCase) private var getEIDRequestCaseListUseCase: GetEIDRequestCaseListUseCaseProtocol
  @ObservationIgnored @Injected(\.updateEIDRequestCaseStatusUseCase) private var updateEIDRequestCaseStatusUseCase: UpdateEIDRequestCaseStatusUseCaseProtocol
  @ObservationIgnored @Injected(\.refreshCredentialsUseCase) private var refreshCredentialsUseCase: RefreshCredentialsUseCaseProtocol
  @ObservationIgnored @Injected(\.isOTPEnabledUseCase) private var isOTPEnabledUseCase: IsOTPEnabledUseCaseProtocol
  @ObservationIgnored @Injected(\.requestCasePollingManager) private var requestCasePollingManager: RequestCasePollingProtocol
  @ObservationIgnored @Injected(\.updatePushTokenUseCase) private var updatePushTokenUseCase: UpdatePushTokenUseCaseProtocol
  @ObservationIgnored @Injected(\.resetApplicationBadgeUseCase) private var resetApplicationBadgeUseCase: ResetApplicationBadgeUseCaseProtocol

  private func fetchData() async {
    await withTaskGroup(of: Void.self) { group in
      group.addTask { await self.fetchCredentials() }
      group.addTask { await self.getEIDRequestCases() }

      await group.waitForAll()
    }
  }

  private func registerNotificationListeners() {
    notificationTasks.append(
      Task { [weak self] in
        for await _ in NotificationCenter.default.notifications(named: .didLogin) {
          await self?.didLogin()
        }
      })
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

  func openScanner(tab: InvitationTab = .scan) {
    destination = .external(.invitation(tab))
  }

  func openSettings() {
    destination = .external(.settings)
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
    destination = .external(.betaId)
  }

  func openEIDRequest() {
    if isOTPEnabledUseCase() {
      destination = .external(.otp)
    } else {
      destination = .external(.eIDRequest)
    }
  }

  func openHelp() {
    externalURL = URL(string: L10n.tkSettingsGeneralHelpLinkValue)
  }

  func didConsumeExternalURL() {
    externalURL = nil
  }

  // MARK: Private

  private func openVerifiableCredential(_ verifiableCredential: VerifiableCredential) {
    switch verifiableCredential.progressionState {
    case .accepted:
      destination = .external(.credentialDetail(CredentialDetailInput(credential: verifiableCredential)))
    case .unaccepted:
      destination = .external(.offer(verifiableCredential))
    }
  }

  private func openDeferredCredential(_ deferredCredential: DeferredCredential) {
    destination = .external(.credentialDetail(CredentialDetailInput(credential: deferredCredential)))
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
      if credentials.isEmpty {
        let allCredentials = try await getCredentialListUseCase()
        updateView(with: allCredentials)
      }

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

  private func updateView(with credentials: [any CredentialProtocol]) {
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
      let temporaryRequestCases = try await getEIDRequestCaseListUseCase()
      updateView(with: temporaryRequestCases)

      await refreshRequestCases()
      await checkPushTokenValidity()
    } catch {}
  }

  @MainActor
  private func refreshRequestCases() async {
    do {
      try await updateEIDRequestCaseStatusUseCase.execute(requestCases.map(\.id))
      let requestCases = try await getEIDRequestCaseListUseCase()
      updateView(with: requestCases)
      try await resetApplicationBadgeUseCase()
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

  private func checkPushTokenValidity() async {
    try? await updatePushTokenUseCase()
  }
}

// MARK: RequestCaseViewStateDelegate

extension HomeViewModel: RequestCaseViewStateDelegate {
  func didDeleteRequestCase() {
    Task {
      await getEIDRequestCases()
      await refreshCredentials()
    }
  }

  func didStartAutoVerification(caseId: String) {
    destination = .external(.autoVerification(caseId))
  }

  func didUpdateRequestCaseState() {
    Task {
      await refreshRequestCases()
    }
  }

  func didTapObtainConsent(caseId: String) {
    destination = .external(.obtainConsent(caseId))
  }

  func didOpenExternalLink(url: URL) {
    externalURL = url
  }

  func didTapWalletPairing(caseId: String) {
    destination = .external(.walletPairing(caseId))
  }

  func didTapIdentityCheck(caseId: String) {
    destination = .external(.identityCheck(caseId))
  }
}

// MARK: Navigation Checkpoint

extension HomeViewModel {

  // MARK: Internal

  func handleNavigationCheckpoint(state: HomeCheckpointsState?) async {
    if let state {
      switch state {
      case .acceptCredential:
        didSaveCredential()

      case .declineCredential:
        didDeclineCredential()

      case .deletedCredential:
        didDeleteCredential()

      case .startRequestCasePolling(let caseId):
        startRequestCasePolling(for: caseId)
      }
    }

    await refresh()
  }

  // MARK: Private

  private func didSaveCredential() {
    toast = Toast(L10n.tkHomeNotificationCredentialAccepted)
  }

  private func didDeclineCredential() {
    toast = Toast(L10n.tkHomeNotificationCredentialDeclined)
  }

  private func didDeleteCredential() {
    toast = Toast(L10n.tkHomeNotificationCredentialDeleted)
  }

  private func startRequestCasePolling(for caseId: String) {
    requestCasePollingManager.startPolling(for: caseId)
  }
}

// MARK: @MainActor RequestCasePollingDelegate

extension HomeViewModel: @MainActor RequestCasePollingDelegate {
  func didCompletePolling(with _: EIDRequestStatus.State) {
    Task {
      await refreshRequestCases()
    }
  }
}
