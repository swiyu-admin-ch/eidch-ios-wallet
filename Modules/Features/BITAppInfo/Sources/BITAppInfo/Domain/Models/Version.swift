import BITCore
import Foundation

// MARK: - Version

public struct Version: Equatable, Comparable {

  // MARK: Lifecycle

  public init(_ version: String) {
    rawValue = version
    (major, minor, patch) = Version.parse(version, pattern: regex)
  }

  // MARK: Public

  public typealias Major = Int
  public typealias Minor = Int
  public typealias Patch = Int
  public typealias VersionFormat = (major: Major, minor: Minor, patch: Patch)

  public let rawValue: String

  public var version: VersionFormat {
    (major, minor, patch)
  }

  public static func == (lhs: Version, rhs: Version) -> Bool {
    lhs.major == rhs.major &&
      lhs.minor == rhs.minor &&
      lhs.patch == rhs.patch
  }

  public static func < (lhs: Version, rhs: Version) -> Bool {
    (lhs.major, lhs.minor, lhs.patch) < (rhs.major, rhs.minor, rhs.patch)
  }

  public static func > (lhs: Version, rhs: Version) -> Bool {
    (lhs.major, lhs.minor, lhs.patch) > (rhs.major, rhs.minor, rhs.patch)
  }

  // MARK: Internal

  enum VersionKind: String, CaseIterable {
    case major
    case minor
    case patch
  }

  let major: Major
  let minor: Minor
  let patch: Patch

  // MARK: Private

  private let regex = #"(?<major>\d+)(.(?<minor>\d+))?(.(?<patch>\d+))?"#

  private static func parse(_ version: String, pattern: String) -> VersionFormat {
    var finalVersion: VersionFormat = (0, 0, 0)
    guard let regex = try? Regex(pattern), let match = version.wholeMatch(of: regex) else {
      return finalVersion
    }

    let captures = match.output.filter { $0.name != nil }
    for (idx, name) in VersionKind.allCases.enumerated() {
      guard let capture = captures[idx].value as? Substring else { continue }
      switch name {
      case .major:
        finalVersion.major = Int(capture) ?? 0
      case .minor:
        finalVersion.minor = Int(capture) ?? 0
      case .patch:
        finalVersion.patch = Int(capture) ?? 0
      }
    }

    return finalVersion
  }

}

// MARK: Version.Mock

extension Version {
  public enum Mock {
    public static let sample = Version("1.2.3")
  }
}
