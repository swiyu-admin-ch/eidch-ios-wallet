import BITAnalytics
import BITNetworking
import Factory
import Foundation
import Spyable

// MARK: - VersionEnforcementRepositoryProtocol

@Spyable
public protocol VersionEnforcementRepositoryProtocol {
  func fetchVersionEnforcements() async throws -> [VersionEnforcement]
}

// MARK: - VersionEnforcementRepository

struct VersionEnforcementRepository: VersionEnforcementRepositoryProtocol {

  func fetchVersionEnforcements() async throws -> [VersionEnforcement] {
    do {
      let versionEnforcements: [VersionEnforcement] = try await networkService.request(VersionEnforcementEndpoint.configuration(versionEnforcementUrl: versionEnforcementUrl))
      return versionEnforcements.sorted(by: { $0.created > $1.created })
    } catch let error as NetworkError where error.status == .pinning {
      analytics.log(AnalyticsEvent.versionEnforcementServerEvaluationFailed)
      throw error
    } catch {
      throw error
    }
  }

  // MARK: Private

  @Injected(\.versionEnforcementUrl) private var versionEnforcementUrl: URL
  @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @Injected(\NetworkContainer.service) private var networkService: NetworkService
}

// MARK: VersionEnforcementRepository.AnalyticsEvent

extension VersionEnforcementRepository {
  enum AnalyticsEvent: AnalyticsEventProtocol {
    case versionEnforcementServerEvaluationFailed
  }
}
