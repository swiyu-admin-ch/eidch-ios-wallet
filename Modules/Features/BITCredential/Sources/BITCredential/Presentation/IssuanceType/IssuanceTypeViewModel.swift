import BITCore
import BITCredentialShared
import Factory
import Foundation

// MARK: - IssuanceTypeViewModelError

enum IssuanceTypeViewModelError: Error {
  case unsupportedCredentialType
}

// MARK: - IssuanceTypeViewModel

@MainActor
@Observable
final class IssuanceTypeViewModel {

  // MARK: Lifecycle

  init(credentialId: UUID) {
    self.credentialId = credentialId
  }

  // MARK: Internal

  struct BatchViewModel: Hashable {
    let available: Int
    let refreshThreshold: Int

    var isBatchPrivacyWarningVisible: Bool {
      available == 0
    }
  }

  enum IssuanceType: Hashable {
    case single
    case batch(BatchViewModel)
  }

  enum State {
    case loading
    case result(type: IssuanceType, timeStamp: String)
    case error(Error)
  }

  enum NotificationState: Equatable {
    case success, failure
  }

  var state = State.loading
  var notificationState: NotificationState?

  private(set) var isRefreshing = false

  func onAppear() async {
    state = .loading

    do {
      try await prepareCredentialIssuanceSummaryState()
    } catch {
      state = .error(error)
    }
  }

  func refreshBatchCredential() async {
    isRefreshing = true
    defer { isRefreshing = false }

    do {
      guard let credential = try await getCredentialUseCase(id: credentialId) as? VerifiableCredential else {
        throw IssuanceTypeViewModelError.unsupportedCredentialType
      }

      _ = try await refreshCredentialUseCase(credential)
      try await prepareCredentialIssuanceSummaryState()

      notificationState = .success
    } catch {
      notificationState = .failure
    }
  }

  // MARK: Private

  private let credentialId: UUID

  @ObservationIgnored @Injected(\.getCredentialIssuanceSummaryUseCase) private var getCredentialIssuanceSummaryUseCase: GetCredentialIssuanceSummaryUseCaseProtocol
  @ObservationIgnored @Injected(\.getCredentialRefreshThresholdUseCase) private var getCredentialRefreshThresholdUseCase: GetCredentialRefreshThresholdUseCaseProtocol
  @ObservationIgnored @Injected(\.getCredentialUseCase) private var getCredentialUseCase: GetCredentialUseCaseProtocol
  @ObservationIgnored @Injected(\.refreshCredentialUseCase) private var refreshCredentialUseCase: RefreshVerifiableCredentialUseCaseProtocol

  private var currentLocale: Locale {
    Locale(identifier: Container.shared.preferredUserLocales().first ?? UserLocale.defaultLocaleIdentifier)
  }

  private func timeStamp(from issuedAt: Date) -> String {
    let date = issuedAt.formatted(
      .dateTime
        .locale(currentLocale)
        .year(.defaultDigits)
        .month(.twoDigits)
        .day(.twoDigits))
    let time = issuedAt.formatted(
      .dateTime
        .locale(currentLocale)
        .hour(.twoDigits(amPM: .abbreviated))
        .minute(.twoDigits))
    return "\(date) | \(time)"
  }

  private func type(from summary: CredentialIssuanceSummary) -> IssuanceType {
    if summary.total <= 1 {
      .single
    } else {
      .batch(
        BatchViewModel(
          available: summary.available,
          refreshThreshold: getCredentialRefreshThresholdUseCase(for: summary.total)))
    }
  }

  private func prepareCredentialIssuanceSummaryState() async throws {
    let summary = try await getCredentialIssuanceSummaryUseCase(for: credentialId)
    state = .result(type: type(from: summary), timeStamp: timeStamp(from: summary.issuedAt))
  }
}
