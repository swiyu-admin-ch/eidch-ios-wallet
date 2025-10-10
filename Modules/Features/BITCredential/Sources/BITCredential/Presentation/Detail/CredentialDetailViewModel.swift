import BITAnalytics
import BITCredentialShared
import Factory
import Foundation
import UIKit

// MARK: - CredentialDetailViewModel

@MainActor
class CredentialDetailViewModel: ObservableObject {

  // MARK: Lifecycle

  init(_ credential: VerifiableCredential, router: CredentialDetailInternalRoutes) {
    self.credential = credential
    self.router = router
    configureObservers()
  }

  // MARK: Internal

  enum AnalyticsEvent: AnalyticsEventProtocol {
    case checkStatusFailed
    case deleteCredentialError(_ error: Error)
  }

  @Published var credentialViewModel: CredentialViewModel?
  @Published var isDeleteCredentialAlertPresented = false

  @Published var credential: VerifiableCredential {
    didSet {
      updateCredentialViewModel(with: colorScheme)
    }
  }

  func deleteCredential() async {
    do {
      try await deleteCredentialUseCase.execute(credential)
      close()
    } catch {
      analytics.log(AnalyticsEvent.deleteCredentialError(error))
    }
  }

  func onAppear() async {
    await updateCredentialStatus()
  }

  func refresh() async {
    await updateCredentialStatus()
  }

  func openWrongdata() {
    router.wrongData()
  }

  func close() {
    router.close()
  }

  func updateCredentialViewModel(with colorScheme: String) {
    self.colorScheme = colorScheme
    let display = getCredentialDisplayUseCase.execute(for: credential.displays, colorScheme: colorScheme)
    credentialViewModel = CredentialViewModel(credential: credential, credentialDisplay: display)
  }

  // MARK: Private

  private var colorScheme = String()

  private let router: CredentialDetailInternalRoutes
  @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @Injected(\.deleteCredentialUseCase) private var deleteCredentialUseCase: DeleteCredentialUseCaseProtocol
  @Injected(\.checkAndUpdateCredentialStatusUseCase) private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocol
  @Injected(\.getCredentialDisplayUseCase) private var getCredentialDisplayUseCase: GetCredentialDisplayUseCaseProtocol

  private func updateCredentialStatus() async {
    guard let credential = try? await checkAndUpdateCredentialStatusUseCase.execute(for: credential) else {
      return analytics.log(AnalyticsEvent.checkStatusFailed)
    }

    self.credential = credential
  }

  private func configureObservers() {
    NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { _ in
      Task { @MainActor [weak self] in
        self?.isDeleteCredentialAlertPresented = false
      }
    }
  }
}
