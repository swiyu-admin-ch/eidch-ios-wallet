import BITAnalytics
import BITAppAuth
import BITCore
import BITCredential
import BITCredentialShared
import BITEIDRequest
import BITEntities
import BITL10n
import Combine
import Factory
import Foundation
import RealmSwift
import SwiftUI

// MARK: - HomeViewModel

class HomeViewModel: StateMachine<HomeViewModel.State, HomeViewModel.Event> {

  // MARK: Lifecycle

  init(
    _ initialState: State = .results,
    router: HomeRouterRoutes,
    credentials: [Credential] = [],
    notificationCenter: NotificationCenter = NotificationCenter.default)
  {
    self.credentials = credentials
    self.router = router
    self.notificationCenter = notificationCenter

    super.init(initialState)
    registerNotifications()
  }

  // MARK: Internal

  enum State: Equatable {
    case results
    case error
    case empty
  }

  enum Event {
    case fetchCredentials
    case didFetchCredentials(_ credentials: [Credential])
    case checkCredentialsStatus
    case didCheckCredentialsStatus
    case didCheckCredentialsStatusWithError(_ error: Error)

    case refresh
    case setError(_ error: Error)
  }

  @Published var requestCases: [RequestCaseViewState] = []
  @Published var credentials: [Credential] = []
  @Published var isImpressumPresented = false
  @Published var isSecurityPresented = false
  @Published var isLicensesPresented = false
  @Published var isVerificationInstructionPresented = false

  @Injected(\.isEIDRequestFeatureEnabled) var isEIDRequestFeatureEnabled: Bool

  override func reducer(_ state: inout State, _ event: Event) -> AnyPublisher<Event, Never>? {
    switch (state, event) {
    case (_, .fetchCredentials):
      return AnyPublisher.run {
        try await self.getCredentialListUseCase.execute()
      } onSuccess: { credentials in
        .didFetchCredentials(credentials)
      } onError: { error in
        .setError(error)
      }

    case (_, .didFetchCredentials(let credentials)):
      stateError = nil

      if credentials.isEmpty {
        state = .empty
        return nil
      }

      state = .results
      withAnimation {
        self.credentials = credentials
      }

    case (_, .refresh):
      return Just(.fetchCredentials).eraseToAnyPublisher()

    case (_, .checkCredentialsStatus):
      return AnyPublisher.run {
        try await self.checkAndUpdateCredentialStatusUseCase.execute(self.credentials)
      } onSuccess: { _ in
        .fetchCredentials
      } onError: { error in
        self.analytics.log(error)
        return .didCheckCredentialsStatusWithError(error)
      }

    case (_, .didCheckCredentialsStatus),
         (_, .didCheckCredentialsStatusWithError(_)):
      return nil

    case (_, .setError(let error)):
      analytics.log(error)

      if credentials.isEmpty {
        state = .error
      }

      stateError = error
    }

    return nil
  }

  func onAppear() async {
    if isEIDRequestFeatureEnabled, isEIDRequestAfterOnboardingEnabledUseCase.execute() {
      router.eIDRequest()
      enableEIDRequestAfterOnboardingUseCase.execute(false)
    }

    if isUserLoggedInUseCase.execute() {
      await send(event: .refresh)
    }
  }

  func getEIDRequestCases() async {
    do {
      requestCases = try await getEIDRequestCaseListUseCase.execute()
        .map { try RequestCaseViewState($0, delegate: self) }

      if !requestCases.isEmpty {
        await fetchEIDRequestStatus()
      }
    } catch {
      requestCases = []
    }
  }

  func fetchEIDRequestStatus() async {
    do {
      requestCases = try await updateEIDRequestCaseStatusUseCase.execute(requestCases.map(\.id))
        .map { try RequestCaseViewState($0, delegate: self) }
    } catch {
      // Request cases list is not updated if error
    }
  }

  // MARK: Private

  private let router: HomeRouterRoutes

  private let notificationCenter: NotificationCenter
  @Injected(\.getCredentialListUseCase) private var getCredentialListUseCase: GetCredentialListUseCaseProtocol
  @Injected(\.checkAndUpdateCredentialStatusUseCase) private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocol
  @Injected(\.isUserLoggedInUseCase) private var isUserLoggedInUseCase: IsUserLoggedInUseCaseProtocol
  @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @Injected(\.isEIDRequestAfterOnboardingEnabledUseCase) private var isEIDRequestAfterOnboardingEnabledUseCase: IsEIDRequestAfterOnboardingEnabledUseCaseProtocol
  @Injected(\.enableEIDRequestAfterOnboardingUseCase) private var enableEIDRequestAfterOnboardingUseCase: EnableEIDRequestAfterOnboardingUseCaseProtocol
  @Injected(\.getEIDRequestCaseListUseCase) private var getEIDRequestCaseListUseCase: GetEIDRequestCaseListUseCaseProtocol
  @Injected(\.updateEIDRequestCaseStatusUseCase) private var updateEIDRequestCaseStatusUseCase: UpdateEIDRequestCaseStatusUseCaseProtocol

  private func registerNotifications() {
    notificationCenter.addObserver(forName: .didLogin, object: nil, queue: .main, using: { [weak self] _ in self?.onDidLogin() })
  }

  private func onDidLogin() {
    Task {
      await send(event: .refresh)
      await send(event: .checkCredentialsStatus)
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
    guard let url = URL(string: L10n.settingsHelpLink) else { return }
    router.openExternalLink(url: url)
  }

  func openContact() {
    guard let url = URL(string: L10n.settingsContactLink) else { return }
    router.openExternalLink(url: url)
  }

  func openFeedback() {
    guard let url = URL(string: L10n.tkMenuSettingWalletFeedbackLinkValue) else { return }
    router.openExternalLink(url: url)
  }

  func openImpressum() {
    isImpressumPresented = true
  }

  func openLicenses() {
    isLicensesPresented = true
  }

  func openSecurity() {
    isSecurityPresented = true
  }

  func openDetail(for credential: Credential) {
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
      await fetchEIDRequestStatus()
    }
  }

  func didStartAutoVerification() {
    router.autoVerification()
  }
}
