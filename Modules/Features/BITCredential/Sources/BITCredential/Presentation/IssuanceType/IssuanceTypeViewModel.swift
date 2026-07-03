import BITCore
import BITCredentialShared
import Factory
import Foundation

// MARK: - IssuanceTypeViewModel

@MainActor
@Observable
class IssuanceTypeViewModel {

  // MARK: Lifecycle

  init(credentialId: UUID) {
    self.credentialId = credentialId
  }

  // MARK: Internal

  struct BatchViewModel: Hashable {
    let available: Int
    let total: Int
    let refreshThreshold: Int
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

  var state = State.loading

  func onAppear() async {
    state = .loading

    do {
      let summary = try await getCredentialIssuanceSummaryUseCase.execute(for: credentialId)
      state = .result(type: type(from: summary), timeStamp: timeStamp(from: summary.issuedAt))
    } catch {
      state = .error(error)
    }
  }

  // MARK: Private

  private let credentialId: UUID

  @ObservationIgnored @Injected(\.getCredentialIssuanceSummaryUseCase) private var getCredentialIssuanceSummaryUseCase: GetCredentialIssuanceSummaryUseCaseProtocol
  @ObservationIgnored @Injected(\.getCredentialRefreshThresholdUseCase) private var getCredentialRefreshThresholdUseCase: GetCredentialRefreshThresholdUseCaseProtocol

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
          total: summary.total,
          refreshThreshold: getCredentialRefreshThresholdUseCase(for: summary.total)))
    }
  }

}
