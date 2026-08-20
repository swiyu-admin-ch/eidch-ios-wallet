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

    return VersionEnforcement(
      type: enforcementType(for: preferredVersion, response),
      messages: preferredVersion.message)
  }

  private func preferredVersion(for response: VersionEnforcement.Response) throws -> VersionEnforcement.Response.Version? {
    let appVersion = try getAppVersionUseCase().rawValue

    return preferredForcedVersion(response, appVersion) ??
      preferredOptionalVersion(response, appVersion)
  }

  private func preferredForcedVersion(_ response: VersionEnforcement.Response, _ appVersion: String) -> VersionEnforcement.Response.Version? {
    response.versions
      .filter { $0.updateType == .forced && $0.version > appVersion }
      .sorted { $0.version > $1.version }
      .first
  }

  private func preferredOptionalVersion(_ response: VersionEnforcement.Response, _ appVersion: String) -> VersionEnforcement.Response.Version? {
    let optionalVersions = response.versions
      .filter { $0.updateType == .optional && $0.version >= appVersion }

    return preferredOptionalVersion(expired: true, in: optionalVersions, response) ??
      preferredOptionalVersion(expired: false, in: optionalVersions, response)
  }

  private func preferredOptionalVersion(expired: Bool, in optionalVersions: [VersionEnforcement.Response.Version], _ response: VersionEnforcement.Response) -> VersionEnforcement.Response.Version? {
    optionalVersions
      .filter { hasVersionExpired($0, response: response) == expired }
      .sorted { $0.version > $1.version }
      .first
  }

  private func hasVersionExpired(_ version: VersionEnforcement.Response.Version, response: VersionEnforcement.Response) -> Bool {
    hasSupportVersionExpired(version) ||
      hasLifetimeVersionExpired(version, response: response)
  }

  private func hasSupportVersionExpired(_ enforcement: VersionEnforcement.Response.Version) -> Bool {
    guard let supportGuaranteedUntil = enforcement.supportGuaranteedUntil else {
      return false
    }

    return supportGuaranteedUntil <= currentDate
  }

  private func hasLifetimeVersionExpired(_ enforcement: VersionEnforcement.Response.Version, response: VersionEnforcement.Response) -> Bool {
    let lifetimeDays = response.defaultReleaseSupportDays
    guard let lifetimeLimitDate = calendar.date(byAdding: .day, value: lifetimeDays, to: enforcement.releaseDate) else {
      return false
    }

    return lifetimeLimitDate <= currentDate
  }

  private func enforcementType(for preferredVersion: VersionEnforcement.Response.Version, _ response: VersionEnforcement.Response) -> VersionEnforcementType {
    switch preferredVersion.updateType {
    case .forced:
      .forced
    case .optional:
      hasVersionExpired(preferredVersion, response: response) ? .forced : .optional
    }
  }
}
