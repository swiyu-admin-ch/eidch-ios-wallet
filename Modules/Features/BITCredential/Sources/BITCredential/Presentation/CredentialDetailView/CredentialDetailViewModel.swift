import BITActivity
import BITAnalytics
import BITCredentialShared
import BITL10n
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

  init(_ credentialId: UUID, getActivityHistoryEnabledSubject: GetActivityHistoryEnabledSubjectUseCaseProtocol) {
    self.credentialId = credentialId
    configureObservers(getActivityHistoryEnabledSubject: getActivityHistoryEnabledSubject)
    updateCredentialViewModel(with: colorScheme)
  }

  // MARK: Internal

  enum AnalyticsEvent: AnalyticsEventProtocol {
    case checkStatusFailed
    case deleteCredentialError(_ error: Error)
    case fetchCredentialError(_ error: Error)
    case refreshCredentialError(_ error: Error)
  }

  var credentialViewModel: (any CredentialViewModelProtocol & CredentialCardViewModelProtocol)?
  var isDeleteCredentialAlertPresented = false
  var isCredentialDeleted = false
  var isLoading = true
  var error: Error?
  var isRefreshLoading = false
  var isRefreshErrorPresented = false
  var toast: Toast?
  var activities = [ActivityCellViewModel]()
  var isActivityHistoryEnabled = true

  var credential: CredentialProtocol? {
    didSet {
      updateCredentialViewModel(with: colorScheme)
    }
  }

  var isBatchPrivacyWarningVisible: Bool {
    credentialViewModel?.isBatchPrivacyWarningVisible ?? false
  }

  func deleteCredential() async {
    guard let credential else { return }

    do {
      try await deleteCredentialUseCase.execute(credential)
      isCredentialDeleted = true
    } catch {
      analytics.log(AnalyticsEvent.deleteCredentialError(error))
    }
  }

  func onAppear() async {
    isLoading = credential == nil
    guard await fetchCredential() else { return }

    fetchActivities()
    await updateCredentialStatus()
    isLoading = false
  }

  func refresh() async {
    await updateCredentialStatus()
  }

  func updateCredentialViewModel(with colorScheme: String) {
    self.colorScheme = colorScheme

    guard let credential else {
      credentialViewModel = nil
      return
    }

    credentialViewModel = switch credential {
    case let verifiableCredential as VerifiableCredential:
      VerifiableCredentialViewModel(credential: verifiableCredential, colorScheme: colorScheme)
    case let deferredCredential as DeferredCredential:
      DeferredCredentialViewModel(credential: deferredCredential, colorScheme: colorScheme)
    default: nil
    }
  }

  func handleCredentialRefreshed(_ refreshedCredential: VerifiableCredential) {
    credential = refreshedCredential
    toast = Toast(L10n.tkDisplayrefreshNotificationSuccess)
  }

  func refreshBatchCredential() async {
    guard
      !isRefreshLoading,
      isBatchPrivacyWarningVisible,
      let credential = actionableBatchCredential
    else {
      return
    }

    isRefreshErrorPresented = false
    isRefreshLoading = true
    defer { isRefreshLoading = false }

    do {
      let refreshedCredential = try await refreshCredentialUseCase(credential)
      handleCredentialRefreshed(refreshedCredential)
    } catch {
      analytics.log(AnalyticsEvent.refreshCredentialError(error))
      isRefreshErrorPresented = true
    }
  }

  func hideRefreshError() {
    isRefreshErrorPresented = false
  }

  // MARK: Private

  private let credentialId: UUID
  private var colorScheme = String()

  @ObservationIgnored @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @ObservationIgnored @Injected(\.deleteCredentialUseCase) private var deleteCredentialUseCase: DeleteCredentialUseCaseProtocol
  @ObservationIgnored @Injected(\.checkAndUpdateCredentialStatusUseCase) private var checkAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocol
  @ObservationIgnored @Injected(\.getCredentialUseCase) private var getCredentialUseCase
  @ObservationIgnored @Injected(\.refreshCredentialUseCase) private var refreshCredentialUseCase: RefreshVerifiableCredentialUseCaseProtocol
  @ObservationIgnored @Injected(\.getCredentialActivitiesUseCase) private var getCredentialActivitiesUseCase

  @ObservationIgnored private var cancellables = Set<AnyCancellable>()

  private var actionableBatchCredential: VerifiableCredential? {
    guard isBatchPrivacyWarningVisible else { return nil }
    return credential as? VerifiableCredential
  }

  private func fetchCredential() async -> Bool {
    do {
      error = nil
      credential = try await getCredentialUseCase(id: credentialId)
      return true
    } catch {
      isLoading = false
      self.error = error
      analytics.log(AnalyticsEvent.fetchCredentialError(error))
      return false
    }
  }

  private func fetchActivities() {
    guard let credential, let verifiableCredential = credential as? VerifiableCredential else {
      return
    }

    try? withAnimation {
      self.activities = try getCredentialActivitiesUseCase(for: verifiableCredential.id, limit: 2)
        .map(ActivityCellViewModel.init)
    }
  }

  private func updateCredentialStatus() async {
    guard let credential, let verifiableCredential = credential as? VerifiableCredential else {
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
