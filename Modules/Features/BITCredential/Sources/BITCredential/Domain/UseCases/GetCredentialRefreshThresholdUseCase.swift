import Foundation
import Spyable

// MARK: - GetCredentialRefreshThresholdUseCaseProtocol

@Spyable
protocol GetCredentialRefreshThresholdUseCaseProtocol {
  func callAsFunction(for batchSize: Int) -> Int
}

// MARK: - GetCredentialRefreshThresholdUseCase

struct GetCredentialRefreshThresholdUseCase: GetCredentialRefreshThresholdUseCaseProtocol {

  func callAsFunction(for batchSize: Int) -> Int {
    let ratioThreshold = Int(ceil(Double(batchSize) * Self.refreshThresholdRatio))
    return max(Self.minimumRefreshThreshold, ratioThreshold)
  }

  private static let refreshThresholdRatio = 0.2
  private static let minimumRefreshThreshold = 1
}
