import Factory
import Foundation
import Spyable

// MARK: - FetchVersionEnforcementUseCaseProtocol

@Spyable
public protocol FetchVersionEnforcementUseCaseProtocol {
  func callAsFunction() async throws -> VersionEnforcement?
}

// MARK: - FetchVersionEnforcementUseCase

struct FetchVersionEnforcementUseCase: FetchVersionEnforcementUseCaseProtocol {

  // MARK: Internal

  func callAsFunction() async throws -> VersionEnforcement? {
    let response = try await repository.fetchVersionEnforcement()
    return try enforcement(from: response)
  }

  // MARK: Private

  @Injected(\.versionEnforcementRepository) private var repository
  @Injected(\.getAppVersionUseCase) private var getAppVersionUseCase
  @Injected(\.currentDate) private var currentDate
  @Injected(\.deviceInfoProvider) private var deviceInfoProvider
  @Injected(\.calendar) private var calendar
}

extension FetchVersionEnforcementUseCase {

  private func enforcement(from response: VersionEnforcement.Response) throws -> VersionEnforcement? {
    try checkEnforcementForMinimumOsVersion(response) ??
      checkEnforcementForDeviceBlacklist(response) ??
      checkEnforcementForPreferredVersion(response)
  }

  private func checkEnforcementForMinimumOsVersion(_ response: VersionEnforcement.Response) -> VersionEnforcement? {
    guard let systemVersion = deviceInfoProvider.systemVersion else {
      return nil
    }
    let minimumOsVersion = Version(response.minimumOsVersion)
    return systemVersion < minimumOsVersion ? VersionEnforcement(type: .outdatedOsVersion) : nil
  }

  private func checkEnforcementForDeviceBlacklist(_ response: VersionEnforcement.Response) -> VersionEnforcement? {
    response.deviceBlacklist
      .contains(deviceInfoProvider.modelDescription) ? VersionEnforcement(type: .blacklistedDevice) : nil
  }

  private func checkEnforcementForPreferredVersion(_ response: VersionEnforcement.Response) throws -> VersionEnforcement? {
    guard let preferredVersion = try preferredVersion(for: response) else {
      return nil
    }

    let type: VersionEnforcementType = switch preferredVersion.updateType {
    case .forced: .forced
    case .optional: .optional
    }

    return VersionEnforcement(type: type, messages: preferredVersion.message)
  }

  private func preferredVersion(for response: VersionEnforcement.Response) throws -> VersionEnforcement.Response.Version? {
    let appVersion = try getAppVersionUseCase().rawValue

    return versionForForcedUpgrade(response, appVersion) ??
      versionForOptionalUpgradeForUngaranteedVersion(response, appVersion, currentDate) ??
      versionForOptionalUpgradeForExpiredVersion(response, appVersion, currentDate)
  }

  private func versionForForcedUpgrade(_ response: VersionEnforcement.Response, _ appVersion: String) -> VersionEnforcement.Response.Version? {
    response.versions.first(where: { $0.updateType == .forced && $0.version > appVersion })
  }

  private func versionForOptionalUpgradeForUngaranteedVersion(_ response: VersionEnforcement.Response, _ appVersion: String, _ currentDate: Date) -> VersionEnforcement.Response.Version? {
    response.versions
      .filter { $0.updateType == .optional && $0.version >= appVersion }
      .first {
        guard let supportGuaranteedUntil = $0.supportGuaranteedUntil else { return false }
        return supportGuaranteedUntil <= currentDate
      }
  }

  private func versionForOptionalUpgradeForExpiredVersion(_ response: VersionEnforcement.Response, _ appVersion: String, _ currentDate: Date) -> VersionEnforcement.Response.Version? {
    response.versions
      .filter {
        $0.updateType == .optional && $0.version >= appVersion && $0.supportGuaranteedUntil == nil
      }
      .first {
        let lifetimeDays = response.defaultReleaseSupportDays
        guard let lifetimeLimitDate = calendar.date(byAdding: .day, value: lifetimeDays, to: $0.releaseDate) else {
          return false
        }
        return lifetimeLimitDate <= currentDate
      }
  }
}
