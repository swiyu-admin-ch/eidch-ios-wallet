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

  @Published var eIDRequestCases: [EIDRequestCase] = []
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

  #warning("TODO: Remove the filter when handling .cancelled states")
  func getEIDRequestCases() async {
    eIDRequestCases = (try? await getEIDRequestCaseListUseCase.execute()
      .filter { $0.state?.state != .cancelled }) ?? []

    if !eIDRequestCases.isEmpty {
      await fetchEIDRequestStatus()
    }
  }

  #warning("TODO: Remove the filter when handling .cancelled states")
  func fetchEIDRequestStatus() async {
    do {
      eIDRequestCases = try await updateEIDRequestCaseStatusUseCase.execute(eIDRequestCases)
        .filter { $0.state?.state != .cancelled }
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
  @Injected(\.deleteEIDRequestCaseUseCase) private var deleteEIDRequestCaseUseCase: DeleteEIDRequestCaseUseCaseProtocol

  #warning("TODO: Remove the filter when handling .cancelled states")

  private func deleteEIDRequestCase(_ requestCase: EIDRequestCase) async throws {
    do {
      try await deleteEIDRequestCaseUseCase.execute(requestCase)

      eIDRequestCases = try await getEIDRequestCaseListUseCase.execute()
        .filter { $0.state?.state != .cancelled }
    } catch {
      // Do nothing
    }
  }

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

  func openAutoVerification() {
    router.autoVerification()
  }

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

  func requestCaseAction(_ eidRequestCase: EIDRequestCase) async throws {
    switch eidRequestCase.state?.state {
    case .readyForOnlineSession: openAutoVerification()
    case .expired: try await deleteEIDRequestCase(eidRequestCase)
    case .cancelled,
         .closed,
         .denied,
         .inAutoVerification,
         .inIssuing,
         .inQueue,
         .inTargetWalletPairing,
         .none,
         .readyForEntitlementCheck,
         .unknown: ()
    }
  }

}
