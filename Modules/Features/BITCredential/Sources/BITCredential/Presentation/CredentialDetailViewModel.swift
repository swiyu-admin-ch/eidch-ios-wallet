import BITActivity
import BITAnalytics
import BITCredential
import BITCredentialShared
import Factory
import Foundation
import SwiftUI
import UIKit

// MARK: - CredentialDetailViewModel

@MainActor
class CredentialDetailViewModel: ObservableObject {

  // MARK: Lifecycle

  init(_ credential: VerifiableCredential) {
    self.credential = credential
    configureObservers()
  }

  // MARK: Internal

  enum AnalyticsEvent: AnalyticsEventProtocol {
    case checkStatusFailed
    case deleteCredentialError(_ error: Error)
  }

  @Published var credentialViewModel: VerifiableCredentialViewModel?
  @Published var isDeleteCredentialAlertPresented = false
  @Published var isCredentialDeleted = false
  @Published var activities = [ActivityCellViewModel]()

  @Published var credential: VerifiableCredential {
    didSet {
      updateCredentialViewModel(with: colorScheme)
    }
  }

  func deleteCredential() async {
    do {
      try await deleteCredentialUseCase.execute(credential)
      isCredentialDeleted = true
    } catch {
      analytics.log(AnalyticsEvent.deleteCredentialError(error))
    }
  }

  func onAppear() async {
    fetchActivities()
    await updateCredentialStatus()
  }

  func refresh() async {
    await updateCredentialStatus()
  }

  func updateCredentialViewModel(with colorScheme: String) {
    self.colorScheme = colorScheme
    credentialViewModel = VerifiableCredentialViewModel(credential: credential, colorScheme: colorScheme)
  }

  // MARK: Private

  private var colorScheme = String()

  @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @Injected(\.deleteCredentialUseCase) private var deleteCredentialUseCase: DeleteCredentialUseCaseProtocol
  @Injected(\.checkAndUpdateCredentialStatusUseCase) private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocol
  @Injected(\.getCredentialActivitiesUseCase) private var getCredentialActivitiesUseCase

  private func fetchActivities() {
    try? withAnimation {
      self.activities = try getCredentialActivitiesUseCase(for: credential.id, limit: 2)
        .map(ActivityCellViewModel.init)
    }
  }

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
