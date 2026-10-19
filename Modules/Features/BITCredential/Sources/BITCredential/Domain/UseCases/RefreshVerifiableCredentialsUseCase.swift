import BITAnalytics
import BITAppInfo
import BITCredentialShared
import Factory
import Foundation
import Spyable

// MARK: - RefreshVerifiableCredentialsUseCaseProtocol

@Spyable
protocol RefreshVerifiableCredentialsUseCaseProtocol: Sendable {
  func callAsFunction(_ credentials: [VerifiableCredential]) async
}

// MARK: - RefreshVerifiableCredentialsUseCase

struct RefreshVerifiableCredentialsUseCase: RefreshVerifiableCredentialsUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(_ credentials: [VerifiableCredential]) async {
    let refreshableCredentials = await credentials.asyncFilter { credential in
      if batchThresholdReached(credential) { return true }
      let status = await swissProfileStatusEvaluator(credential) ?? .endOfLife // no profile version on credential, treat it as end of life
      guard await isAllowedToRefresh(credential, status: status) else { return false }
      return status != .current || isInExpiryRange(credential)
    }

    _ = await refreshableCredentials.concurrentMapLimited(maxConcurrentTasks: maxConcurrentRefreshes) {
      await refresh($0)
    }
  }

  // MARK: Private

  @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @Injected(\.refreshCredentialUseCase) private var refreshCredentialUseCase: RefreshVerifiableCredentialUseCaseProtocol
  @Injected(\.getCredentialRefreshThresholdUseCase) private var getCredentialRefreshThresholdUseCase:
    GetCredentialRefreshThresholdUseCaseProtocol
  @Injected(\.maxConcurrentVerifiableCredentialRefreshes) private var maxConcurrentRefreshes: Int
  @Injected(\.swissProfileStatusEvaluator) private var swissProfileStatusEvaluator
  @Injected(\.credentialExpiryRefreshRange) private var credentialExpiryRefreshRange: TimeInterval

  private func batchThresholdReached(_ credential: VerifiableCredential) -> Bool {
    let totalCount = credential.bundleItems.count
    guard totalCount > 1 else { return false }
    let remainingCount = credential.bundleItems.filter { !$0.presented }.count
    let threshold = getCredentialRefreshThresholdUseCase(for: totalCount)
    return remainingCount <= threshold
  }

  private func isAllowedToRefresh(_ credential: VerifiableCredential, status: SwissProfile.Status) async -> Bool {
    guard let lastAttemptAt = credential.lastRefreshAttemptAt else { return true }
    return Container.shared.currentDate().timeIntervalSince(lastAttemptAt) >= status.attemptInterval
  }

  private func refresh(_ credential: VerifiableCredential) async {
    do {
      _ = try await refreshCredentialUseCase(credential)
    } catch {
      analytics.log(error)
    }
  }

  private func isInExpiryRange(_ credential: VerifiableCredential) -> Bool {
    guard let validUntil = credential.validUntil else { return false }
    return validUntil <= Container.shared.currentDate().addingTimeInterval(credentialExpiryRefreshRange)
  }
}

extension SwissProfile.Status {
  fileprivate var attemptInterval: TimeInterval {
    switch self {
    case .current: .days(7)
    case .deprecated: .days(5)
    case .sunset: .days(2)
    case .endOfLife: .days(1)
    }
  }
}
