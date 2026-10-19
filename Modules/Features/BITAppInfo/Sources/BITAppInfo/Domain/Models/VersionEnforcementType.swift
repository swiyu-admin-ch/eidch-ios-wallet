import Foundation

// MARK: - VersionEnforcementType

enum VersionEnforcementType: Sendable {
  case forced(storeURL: URL)
  case optional
  case outdatedOsVersion
  case blacklistedDevice
}

// MARK: Equatable

extension VersionEnforcementType: Equatable {

  static func == (lhs: VersionEnforcementType, rhs: VersionEnforcementType) -> Bool {
    switch (lhs, rhs) {
    case (.forced(let lUrl), .forced(let rUrl)):
      lUrl == rUrl
    case (.optional, .optional): true
    case (.outdatedOsVersion, .outdatedOsVersion): true
    case (.blacklistedDevice, .blacklistedDevice): true
    default: false
    }
  }
}
