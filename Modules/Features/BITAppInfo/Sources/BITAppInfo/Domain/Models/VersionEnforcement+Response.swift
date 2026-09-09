import Foundation

// MARK: - VersionEnforcement.Response

extension VersionEnforcement {

  struct Response: Decodable {

    // MARK: Lifecycle

    init(
      appBundleId: String,
      defaultReleaseSupportDays: Int,
      deviceBlacklist: [String],
      minimumOsVersion: String,
      platform: String,
      versions: [Version],
      swissProfiles: [SwissProfile],
      storeURL: URL)
    {
      self.appBundleId = appBundleId
      self.defaultReleaseSupportDays = defaultReleaseSupportDays
      self.deviceBlacklist = deviceBlacklist
      self.minimumOsVersion = minimumOsVersion
      self.platform = platform
      self.versions = versions
      self.swissProfiles = swissProfiles
      self.storeURL = storeURL
    }

    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      appBundleId = try container.decode(String.self, forKey: .appBundleId)
      defaultReleaseSupportDays = try container.decode(Int.self, forKey: .defaultReleaseSupportDays)
      deviceBlacklist = try container.decode([String].self, forKey: .deviceBlacklist)
      minimumOsVersion = try container.decode(String.self, forKey: .minimumOsVersion)
      platform = try container.decode(String.self, forKey: .platform)
      versions = try container.decode([Version].self, forKey: .versions)

      let lifecycle = try container.decode(SwissProfilesContainer.self, forKey: .swissProfileLifecycle)
      swissProfiles = lifecycle.profiles
      storeURL = try container.decode(URL.self, forKey: .storeURL)
    }

    // MARK: Internal

    let appBundleId: String
    /// Defines default support lifetime of a version release (given by `Version.releaseDate`). Usage:
    /// Lifetime support end date = `Version.releaseDate` + `defaultReleaseSupportDays`
    let defaultReleaseSupportDays: Int
    let deviceBlacklist: [String]
    let minimumOsVersion: String
    let platform: String
    let versions: [Version]
    let swissProfiles: [SwissProfile]
    let storeURL: URL

    // MARK: Private

    private enum CodingKeys: String, CodingKey {
      case appBundleId = "app_id"
      case defaultReleaseSupportDays = "default_support_lifetime_days"
      case deviceBlacklist = "device_blacklist"
      case minimumOsVersion = "minimum_os_version"
      case platform
      case versions
      case swissProfileLifecycle = "swiss_profile_lifecycle"
      case storeURL = "store_url"
    }
  }
}

// MARK: - VersionEnforcement.Response.SwissProfilesContainer

extension VersionEnforcement.Response {
  private struct SwissProfilesContainer: Decodable {

    // MARK: Lifecycle

    init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)

      profiles = try CodingKeys.allCases.flatMap { key in
        try container.decodeIfPresent([SwissProfile].self, forKey: key) ?? []
      }
    }

    // MARK: Internal

    let profiles: [SwissProfile]

    // MARK: Private

    private enum CodingKeys: String, CodingKey, CaseIterable {
      case anchor = "swiss_profile_anchor"
      case issuance = "swiss_profile_issuance"
      case portability = "swiss_profile_portability"
      case proximity = "swiss_profile_proximity"
      case trust = "swiss_profile_trust"
      case vc = "swiss_profile_vc"
      case verification = "swiss_profile_verification"
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
