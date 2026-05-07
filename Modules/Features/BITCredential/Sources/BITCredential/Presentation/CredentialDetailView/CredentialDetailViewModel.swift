import BITActivity
import BITAnalytics
import BITCredentialShared
import BITTheming
import Combine
import Factory
import Foundation
import NavigatorUI
import SwiftUI
import UIKit

// MARK: - CredentialDetailViewModel

@MainActor
@Observable
class CredentialDetailViewModel {

  // MARK: Lifecycle

  init(_ credential: CredentialProtocol, getActivityHistoryEnabledSubject: GetActivityHistoryEnabledSubjectUseCaseProtocol) {
    self.credential = credential
    configureObservers(getActivityHistoryEnabledSubject: getActivityHistoryEnabledSubject)
  }

  // MARK: Internal

  enum AnalyticsEvent: AnalyticsEventProtocol {
    case checkStatusFailed
    case deleteCredentialError(_ error: Error)
  }

  var credentialViewModel: (any CredentialViewModelProtocol & CredentialCardViewModelProtocol)?
  var isDeleteCredentialAlertPresented = false
  var isCredentialDeleted = false
  var activities = [ActivityCellViewModel]()
  var isActivityHistoryEnabled = true

  var credential: CredentialProtocol {
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

    credentialViewModel = switch credential {
    case let verifiableCredential as VerifiableCredential:
      VerifiableCredentialViewModel(credential: verifiableCredential, colorScheme: colorScheme)
    case let deferredCredential as DeferredCredential:
      DeferredCredentialViewModel(credential: deferredCredential, colorScheme: colorScheme)
    default: nil
    }
  }

  // MARK: Private

  private var colorScheme = String()

  @ObservationIgnored @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @ObservationIgnored @Injected(\.deleteCredentialUseCase) private var deleteCredentialUseCase: DeleteCredentialUseCaseProtocol
  @ObservationIgnored @Injected(\.checkAndUpdateCredentialStatusUseCase) private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocol
  @ObservationIgnored @Injected(\.getCredentialActivitiesUseCase) private var getCredentialActivitiesUseCase

  @ObservationIgnored private var cancellables = Set<AnyCancellable>()

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

  private func configureObservers(getActivityHistoryEnabledSubject: GetActivityHistoryEnabledSubjectUseCaseProtocol) {
    NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { _ in
      Task { @MainActor [weak self] in
        self?.isDeleteCredentialAlertPresented = false
      }
    }
    getActivityHistoryEnabledSubject()
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { [weak self] in
        self?.isActivityHistoryEnabled = $0
        self?.fetchActivities()
      }).store(in: &cancellables)
  }
}
