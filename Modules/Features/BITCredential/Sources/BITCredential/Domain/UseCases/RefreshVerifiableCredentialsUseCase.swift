import BITAnalytics
import BITAppInfo
import BITCredentialShared
import Factory
import Foundation
import Spyable

// MARK: - RefreshVerifiableCredentialsUseCaseProtocol

@Spyable
protocol RefreshVerifiableCredentialsUseCaseProtocol {
  func callAsFunction(_ credentials: [VerifiableCredential]) async
}

// MARK: - RefreshVerifiableCredentialsUseCase

struct RefreshVerifiableCredentialsUseCase: RefreshVerifiableCredentialsUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(_ credentials: [VerifiableCredential]) async {
    let swissProfiles = try? await swissProfileLifecycleRepository.fetchSwissProfiles(.verifiableCredential)
    let refreshableCredentials = credentials.filter {
      canBeRefreshed($0) && needsToRefresh($0, swissProfiles: swissProfiles ?? [])
    }

    await withTaskGroup(of: Void.self) { taskGroup in
      var credentialIterator = refreshableCredentials.makeIterator()

      for _ in 0..<maxConcurrentRefreshes {
        guard let credential = credentialIterator.next() else { break }
        taskGroup.addTask {
          await refresh(credential)
        }
      }

      while await taskGroup.next() != nil {
        guard let credential = credentialIterator.next() else { continue }
        taskGroup.addTask {
          await refresh(credential)
        }
      }
    }
  }

  // MARK: Private

  @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @Injected(\.refreshCredentialUseCase) private var refreshCredentialUseCase: RefreshVerifiableCredentialUseCaseProtocol
  @Injected(\.getCredentialRefreshThresholdUseCase) private var getCredentialRefreshThresholdUseCase:
    GetCredentialRefreshThresholdUseCaseProtocol
  @Injected(\.maxConcurrentVerifiableCredentialRefreshes) private var maxConcurrentRefreshes: Int
  @Injected(\.swissProfileLifecycleRepository) private var swissProfileLifecycleRepository
  @Injected(\.createAnyCredentialUseCase) private var createAnyCredentialUseCase
  @Injected(\.credentialExpiryRefreshRange) private var credentialExpiryRefreshRange: TimeInterval

  private func canBeRefreshed(_ credential: VerifiableCredential) -> Bool {
    credential.progressionState == .accepted && credential.authentication.refreshToken != nil
  }

  private func needsToRefresh(_ credential: VerifiableCredential, swissProfiles: [SwissProfile]) -> Bool {
    batchThresholdReached(credential) ||
      getSwissProfileStatus(for: credential, swissProfiles: swissProfiles) != .current ||
      isInExpiryRange(credential)
  }

  private func batchThresholdReached(_ credential: VerifiableCredential) -> Bool {
    let presentedCredentials = credential.bundleItems.filter { !$0.presented }
    let threshold = getCredentialRefreshThresholdUseCase(for: credential.bundleItems.count)
    return credential.bundleItems.count > 1 && presentedCredentials.count <= threshold
  }

  private func getSwissProfileStatus(for credential: VerifiableCredential, swissProfiles: [SwissProfile]) -> SwissProfile.Status? {
    guard let firstBundleItem = credential.bundleItems.first else { return nil }
    let anyCredential = try? createAnyCredentialUseCase.execute(from: firstBundleItem.payload, format: credential.format)
    let version = anyCredential?.swissProfileVersion
    guard swissProfiles.contains(where: { $0.type == .verifiableCredential }) else { return .current } // no info about profile version so assume it's current
    return swissProfiles.getStatus(for: version)
  }

  private func refresh(_ credential: VerifiableCredential) async {
    do {
      _ = try await refreshCredentialUseCase(credential)
    } catch {
      analytics.log(error)
      return
    }
  }

  private func isInExpiryRange(_ credential: VerifiableCredential) -> Bool {
    guard let validUntil = credential.validUntil else { return false }
    return validUntil <= Container.shared.currentDate().addingTimeInterval(credentialExpiryRefreshRange)
  }
}

extension [SwissProfile] {
  fileprivate func getStatus(for version: String?) -> SwissProfile.Status? {
    let vcPrefix = SwissProfile.ProfileType.verifiableCredential.rawValue
    guard
      let version,
      version.hasPrefix(vcPrefix),
      let profile = first(where: { $0.version == version.replacing(vcPrefix + ":", with: "") })
    else { return nil }
    return profile.status
  }
}
