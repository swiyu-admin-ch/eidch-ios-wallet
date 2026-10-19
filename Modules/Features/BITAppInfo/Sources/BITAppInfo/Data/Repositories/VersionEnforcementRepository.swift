import BITAnalytics
import BITCore
import BITNetworking
import Factory
import Foundation
import Moya

// MARK: - VersionEnforcementRepositoryError

enum VersionEnforcementRepositoryError: Error {
  case missingDetachedJWS
}

// MARK: - VersionEnforcementRepository

struct VersionEnforcementRepository: VersionEnforcementRepositoryProtocol, SwissProfileLifecycleRepositoryProtocol {

  // MARK: Internal

  func fetchSwissProfiles(_ type: SwissProfile.ProfileType) async throws -> [SwissProfile] {
    let versionEnforcement = try await fetchVersionEnforcement()
    return versionEnforcement.swissProfiles.filter { $0.type == type }
  }

  func fetchVersionEnforcement() async throws -> VersionEnforcement.Response {
    do {
      return try await cache.get(for: VersionEnforcement.Response.self) {
        try await fetchSignedVersionEnforcement()
      }
    } catch let error as NetworkError where error.status == .pinning {
      analytics.log(AnalyticsEvent.versionEnforcementServerEvaluationFailed)
      throw error
    }
  }

  // MARK: Private

  private static let detachedJWSHeaderField = "detached-jws"

  @Injected(\.versionEnforcementUrl) private var versionEnforcementUrl: URL
  @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @Injected(\NetworkContainer.service) private var networkService: NetworkService
  @Injected(\.versionEnforcementCache) private var cache: CacheManager
  @Injected(\.versionEnforcementSignatureValidator) private var signatureValidator: VersionEnforcementSignatureValidatorProtocol

  private func fetchSignedVersionEnforcement() async throws -> VersionEnforcement.Response {
    let response = try await networkService.request(VersionEnforcementEndpoint.configuration(versionEnforcementUrl: versionEnforcementUrl))
    try await signatureValidator.validate(response.data, detachedJWS: detachedJWS(from: response))

    let decoder = JSONDecoder(dateDecodingStrategy: .formatted(DateFormatter(format: DateFormat.date.rawValue)))
    return try decoder.decode(VersionEnforcement.Response.self, from: response.data)
  }

  private func detachedJWS(from response: Response) throws -> String {
    guard let detachedJWS = response.response?.value(forHTTPHeaderField: Self.detachedJWSHeaderField) else {
      throw VersionEnforcementRepositoryError.missingDetachedJWS
    }
    return detachedJWS
  }
}

// MARK: VersionEnforcementRepository.AnalyticsEvent

extension VersionEnforcementRepository {
  enum AnalyticsEvent: AnalyticsEventProtocol {
    case versionEnforcementServerEvaluationFailed
  }
}
