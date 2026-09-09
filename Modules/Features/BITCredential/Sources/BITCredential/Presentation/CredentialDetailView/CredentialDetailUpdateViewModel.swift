import BITAnalytics
import BITCredentialShared
import BITL10n
import Factory
import Observation

// MARK: - CredentialDetailUpdateViewModel

@MainActor
@Observable
final class CredentialDetailUpdateViewModel {

  // MARK: Lifecycle

  init(credential: CredentialProtocol) {
    self.credential = credential
    issuerDisplay = credential.issuerDisplays.findDisplayWithFallback()
    isLoading = false
    isErrorPresented = false
  }

  // MARK: Internal

  enum AnalyticsEvent: AnalyticsEventProtocol {
    case refreshCredentialError(_ error: Error)
  }

  var isLoading: Bool
  var isErrorPresented: Bool

  let issuerDisplay: CredentialIssuerDisplay?

  var isUpdateEnabled: Bool {
    refreshableCredential?.isRevoked != true
  }

  var isRefreshable: Bool {
    refreshableCredential?.authentication.refreshToken != nil
  }

  var title: String {
    isRefreshable ? L10n.tkDisplayrefreshRefreshableTitle : L10n.tkDisplayrefreshTitle
  }

  var body: String {
    isRefreshable ? L10n.tkDisplayrefreshRefreshableBody : L10n.tkDisplayrefreshBody
  }

  func primaryAction(onSuccess: @escaping (VerifiableCredential) -> Void) async {
    guard !isLoading, let refreshableCredential else {
      return
    }

    isErrorPresented = false
    isLoading = true
    defer { isLoading = false }

    do {
      let refreshedCredential = try await refreshCredentialUseCase(refreshableCredential)
      onSuccess(refreshedCredential)
    } catch {
      analytics.log(AnalyticsEvent.refreshCredentialError(error))
      isErrorPresented = true
    }
  }

  func hideError() {
    isErrorPresented = false
  }

  // MARK: Private

  @ObservationIgnored @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @ObservationIgnored @Injected(\.refreshCredentialUseCase) private var refreshCredentialUseCase: RefreshVerifiableCredentialUseCaseProtocol

  private let credential: CredentialProtocol?

  private var refreshableCredential: VerifiableCredential? {
    guard
      let credential = credential as? VerifiableCredential,
      credential.authentication.refreshToken != nil
    else {
      return nil
    }

    return credential
  }
}
