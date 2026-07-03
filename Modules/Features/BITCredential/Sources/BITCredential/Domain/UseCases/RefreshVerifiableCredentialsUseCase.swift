import BITAnalytics
import BITCredentialShared
import Factory
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
    let refreshableCredentials = credentials.filter(shouldRefresh)

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

  private func shouldRefresh(_ credential: VerifiableCredential) -> Bool {
    guard
      credential.progressionState == .accepted,
      credential.authentication.refreshToken != nil,
      let batchData = credential.batchData
    else {
      return false
    }

    return freshCredentialCount(for: credential) <= refreshThreshold(for: batchData)
  }

  private func refresh(_ credential: VerifiableCredential) async {
    do {
      _ = try await refreshCredentialUseCase(credential)
    } catch {
      analytics.log(error)
      return
    }
  }

  private func freshCredentialCount(for credential: VerifiableCredential) -> Int {
    credential.bundleItems.count { !$0.presented }
  }

  private func refreshThreshold(for batchData: BatchData) -> Int {
    getCredentialRefreshThresholdUseCase(for: batchData.batchSize)
  }

}
