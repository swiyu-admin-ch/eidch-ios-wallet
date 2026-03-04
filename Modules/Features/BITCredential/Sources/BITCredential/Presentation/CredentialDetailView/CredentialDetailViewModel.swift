import BITActivity
import BITAnalytics
import BITCredentialShared
import BITTheming
import Factory
import Foundation
import SwiftUI
import UIKit

// MARK: - CredentialDetailViewModel

@MainActor
class CredentialDetailViewModel: ObservableObject {

  // MARK: Lifecycle

  init(_ credential: CredentialProtocol, delegate: CredentialDetailDelegate?) {
    self.credential = credential
    self.delegate = delegate
    configureObservers()
  }

  // MARK: Internal

  enum AnalyticsEvent: AnalyticsEventProtocol {
    case checkStatusFailed
    case deleteCredentialError(_ error: Error)
  }

  @Published var credentialViewModel: (any CredentialViewModelProtocol & CredentialCardViewModelProtocol)?
  @Published var isDeleteCredentialAlertPresented = false
  @Published var isCredentialDeleted = false
  @Published var activities = [ActivityCellViewModel]()

  @Published var credential: CredentialProtocol {
    didSet {
      updateCredentialViewModel(with: colorScheme)
    }
  }

  func deleteCredential() async {
    do {
      try await deleteCredentialUseCase.execute(credential)
      isCredentialDeleted = true
      delegate?.onCredentialDeleted()
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

    credentialViewModel = switch credential {
    case let verifiableCredential as VerifiableCredential:
      VerifiableCredentialViewModel(credential: verifiableCredential, colorScheme: colorScheme)
    case let deferredCredential as DeferredCredential:
      DeferredCredentialViewModel(credential: deferredCredential, colorScheme: colorScheme)
    default: nil
    }
  }

  // MARK: Private

  private weak var delegate: CredentialDetailDelegate?
  private var colorScheme = String()

  @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @Injected(\.deleteCredentialUseCase) private var deleteCredentialUseCase: DeleteCredentialUseCaseProtocol
  @Injected(\.checkAndUpdateCredentialStatusUseCase) private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocol
  @Injected(\.getCredentialActivitiesUseCase) private var getCredentialActivitiesUseCase

  private func fetchActivities() {
    guard let verifiableCredential = credential as? VerifiableCredential else {
      return
    }

    try? withAnimation {
      self.activities = try getCredentialActivitiesUseCase(for: verifiableCredential.id, limit: 2)
        .map(ActivityCellViewModel.init)
    }
  }

  private func updateCredentialStatus() async {
    guard let verifiableCredential = credential as? VerifiableCredential else {
      return
    }

    guard let credential = try? await checkAndUpdateCredentialStatusUseCase.execute(for: verifiableCredential) else {
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
