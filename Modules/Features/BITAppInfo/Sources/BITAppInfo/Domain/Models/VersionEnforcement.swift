import BITCore

// MARK: - VersionEnforcement

public struct VersionEnforcement: Codable, Equatable {
  let id: String
  let platform: String
  let priority: String
  let created: String
  let criteria: Criteria
  let displays: [Display]

  public static func == (lhs: VersionEnforcement, rhs: VersionEnforcement) -> Bool {
    lhs.id == rhs.id && lhs.platform == rhs.platform && lhs.priority == rhs.priority && lhs.created == rhs.created && lhs.criteria == rhs.criteria && lhs.displays == rhs.displays
  }

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
