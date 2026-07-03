import BITAnalytics
import BITNetworking
import Factory
import Foundation
import Spyable

// MARK: - VersionEnforcementRepositoryProtocol

@Spyable
protocol VersionEnforcementRepositoryProtocol {
  func fetchVersionEnforcement() async throws -> VersionEnforcement.Response
}

// MARK: - VersionEnforcementRepository

struct VersionEnforcementRepository: VersionEnforcementRepositoryProtocol {

  func fetchVersionEnforcement() async throws -> VersionEnforcement.Response {
    do {
      let decoder = JSONDecoder(dateDecodingStrategy: .formatted(DateFormatter(format: "yyyy-MM-dd")))
      return try await networkService.request(VersionEnforcementEndpoint.configuration(versionEnforcementUrl: versionEnforcementUrl), decoder: decoder)
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
