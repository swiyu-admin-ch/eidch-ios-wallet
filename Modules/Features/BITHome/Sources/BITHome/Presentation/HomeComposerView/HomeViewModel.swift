import BITAnalytics
import BITAppAuth
import BITCore
import BITCredential
import BITCredentialShared
import BITEIDRequest
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

    registerNotifications()
  }

  // MARK: Internal

  enum State {
    case results
    case error(_ error: Error)
    case empty
  }

  @Published var state = State.results
  @Published var requestCases = [RequestCaseViewState]()
  @Published var credentialViewModels = [CredentialViewModel]()

  @Injected(\.isEIDRequestFeatureEnabled) var isEIDRequestFeatureEnabled: Bool

  func onAppear() async {
    if isEIDRequestFeatureEnabled, isEIDRequestAfterOnboardingEnabledUseCase.execute() {
      router.eIDRequest()
      enableEIDRequestAfterOnboardingUseCase.execute(false)
    }

    if isUserLoggedInUseCase.execute() {
      await withTaskGroup(of: Void.self) { group in
        group.addTask { await self.fetchCredentials() }
        group.addTask { await self.getEIDRequestCases() }
      }
    }
  }

  func fetchCredentials() async {
    do {
      let credentials = try await getCredentialListUseCase.execute()

      if credentials.isEmpty {
        return setState(.empty)
      }

      setState(.results)
      withAnimation {
        self.credentials = credentials
      }
    } catch {
      analytics.log(error)

      if credentials.isEmpty {
        setState(.error(error))
      }
    }
  }

  func fetchCredentialStatus() async {
    do {
      try await checkAndUpdateCredentialStatusUseCase.execute(credentials)
      await fetchCredentials()
    } catch {
      analytics.log(error)
    }
  }

  @MainActor
  func getEIDRequestCases() async {
    do {
      requestCases = try await getEIDRequestCaseListUseCase.execute()
        .compactMap { try? RequestCaseViewState($0, delegate: self) }

      if !requestCases.isEmpty {
        await fetchRequestCaseStatus()
      }
    } catch {
      requestCases = []
    }
  }

  @MainActor
  func fetchRequestCaseStatus() async {
    do {
      requestCases = try await updateEIDRequestCaseStatusUseCase.execute(requestCases.map(\.requestCaseId))
        .map { try RequestCaseViewState($0, delegate: self) }
    } catch {
      // Request cases list is not updated if error
    }
  }

  func updateCredentialViewModels(with colorScheme: String) {
    self.colorScheme = colorScheme
    credentialViewModels = credentials.map {
      let display = getCredentialDisplayUseCase.execute(for: $0.displays, colorScheme: colorScheme)
      return CredentialViewModel(credential: $0, credentialDisplay: display)
    }
  }

  // MARK: Private

  private var colorScheme = String()
  private let router: HomeRouterRoutes

  @Injected(\.getCredentialListUseCase) private var getCredentialListUseCase: GetCredentialListUseCaseProtocol
  @Injected(\.checkAndUpdateCredentialStatusUseCase) private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocol
  @Injected(\.isUserLoggedInUseCase) private var isUserLoggedInUseCase: IsUserLoggedInUseCaseProtocol
  @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @Injected(\.isEIDRequestAfterOnboardingEnabledUseCase) private var isEIDRequestAfterOnboardingEnabledUseCase: IsEIDRequestAfterOnboardingEnabledUseCaseProtocol
  @Injected(\.enableEIDRequestAfterOnboardingUseCase) private var enableEIDRequestAfterOnboardingUseCase: EnableEIDRequestAfterOnboardingUseCaseProtocol
  @Injected(\.getEIDRequestCaseListUseCase) private var getEIDRequestCaseListUseCase: GetEIDRequestCaseListUseCaseProtocol
  @Injected(\.updateEIDRequestCaseStatusUseCase) private var updateEIDRequestCaseStatusUseCase: UpdateEIDRequestCaseStatusUseCaseProtocol
  @Injected(\.getCredentialDisplayUseCase) private var getCredentialDisplayUseCase: GetCredentialDisplayUseCaseProtocol

  private var credentials = [VerifiableCredential]() {
    didSet {
      updateCredentialViewModels(with: colorScheme)
    }
  }

  private func registerNotifications() {
    NotificationCenter.default.addObserver(forName: .didLogin, object: nil, queue: .main, using: { [weak self] _ in self?.onDidLogin() })
  }

  private func onDidLogin() {
    Task {
      await fetchCredentials()
      await fetchCredentialStatus()
    }
  }

  @MainActor
  private func setState(_ newState: State) {
    withAnimation {
      self.state = newState
    }
  }
}

extension HomeViewModel {

  func openScanner() {
    router.invitation()
  }

  func openSettings() {
    router.settings()
  }

  func openHelp() {
    guard let url = URL(string: L10n.tkSettingsGeneralHelpLinkValue) else { return }
    router.openExternalLink(url: url)
  }

  func openDetail(for credential: VerifiableCredential) {
    router.credentialDetail(credential)
  }

  func openBetaId() {
    router.betaId()
  }

  func openEIDRequest() {
    router.eIDRequest()
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
      await fetchRequestCaseStatus()
    }
  }

  func didTapObtainConsent(caseId: String) {
    router.obtainConsent(caseId: caseId)
  }

  func didOpenExternalLink(url: URL) {
    router.openExternalLink(url: url)
  }
}
