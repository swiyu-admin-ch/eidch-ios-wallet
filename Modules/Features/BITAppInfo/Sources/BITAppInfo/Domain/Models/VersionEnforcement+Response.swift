import Foundation

// MARK: - VersionEnforcement.Response

extension VersionEnforcement {

  struct Response: Decodable {

    // MARK: Internal

    let appBundleId: String
    /// Defines default support lifetime of a version release (given by `Version.releaseDate`). Usage:
    /// Lifetime support end date = `Version.releaseDate` + `defaultReleaseSupportDays`
    let defaultReleaseSupportDays: Int
    let deviceBlacklist: [String]
    let minimumOsVersion: String
    let platform: String
    let versions: [Version]

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
      case appBundleId = "app_id"
      case defaultReleaseSupportDays = "default_support_lifetime_days"
      case deviceBlacklist = "device_blacklist"
      case minimumOsVersion = "minimum_os_version"
      case platform
      case versions
    }
  }
}

extension VersionEnforcement.Response {

  struct Version: Decodable {

    // MARK: Internal

    let message: [VersionEnforcement.Message]
    let releaseDate: Date
    let supportGuaranteedUntil: Date?
    let updateType: UpdateType
    let version: String

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
      case message
      case releaseDate = "release_date"
      case supportGuaranteedUntil = "support_guaranteed_until"
      case updateType = "update_type"
      case version
    }
  }

  enum UpdateType: String, Codable {
    case optional, forced
  }
}
