import BITCore

// MARK: - VersionEnforcement

public struct VersionEnforcement: Codable, Equatable {
  let id: String
  let platform: String
  let priority: String
  let created: String
  let criteria: Criteria
  let displays: [Display]

}

extension VersionEnforcement {

  struct Display: Codable, DisplayLocalizable, Equatable {
    let title: String
    let body: String
    let locale: UserLocale?
  }

  struct Criteria: Codable, Equatable {
    let minAppVersionIncluded: String?
    let maxAppVersionExcluded: String
  }

}
