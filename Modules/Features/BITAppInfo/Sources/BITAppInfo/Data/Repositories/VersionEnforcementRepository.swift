import BITAnalytics
import BITCore
import BITNetworking
import Factory
import Foundation
import Spyable

// MARK: - VersionEnforcementRepository

struct VersionEnforcementRepository: VersionEnforcementRepositoryProtocol, SwissProfileLifecycleRepositoryProtocol {

  // MARK: Internal

  func fetchSwissProfiles(_ type: SwissProfile.ProfileType) async throws -> [SwissProfile] {
    let versionEnforcement = try await fetchVersionEnforcement()
    return versionEnforcement.swissProfiles.filter { $0.type == type }
  }

  func fetchVersionEnforcement() async throws -> VersionEnforcement.Response {
    do {
      let decoder = JSONDecoder(dateDecodingStrategy: .formatted(DateFormatter(format: "yyyy-MM-dd")))
      return try await cache.get(for: VersionEnforcement.Response.self) {
        try await networkService.request(VersionEnforcementEndpoint.configuration(versionEnforcementUrl: versionEnforcementUrl), decoder: decoder)
      }
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
  @Injected(\.versionEnforcementCache) private var cache: CacheManager
}

// MARK: VersionEnforcementRepository.AnalyticsEvent

extension VersionEnforcementRepository {
  enum AnalyticsEvent: AnalyticsEventProtocol {
    case versionEnforcementServerEvaluationFailed
  }
}
