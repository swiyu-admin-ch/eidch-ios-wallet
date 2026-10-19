import BITCore
import Foundation

public struct SwissProfile: Changeable, Codable, Sendable {

  // MARK: Public

  public enum ProfileType: String, Codable, CaseIterable, Sendable {
    case anchor = "swiss-profile-anchor"
    case issuance = "swiss-profile-issuance"
    case portability = "swiss-profile-portability"
    case proximity = "swiss-profile-proximity"
    case trust = "swiss-profile-trust"
    case verifiableCredential = "swiss-profile-vc"
    case verification = "swiss-profile-verification"
  }

  public enum Status: String, Codable, CaseIterable, Sendable, Comparable {
    case current
    case deprecated
    case sunset
    case endOfLife = "eol"

    public static func < (lhs: SwissProfile.Status, rhs: SwissProfile.Status) -> Bool {
      lhs.sortOrder < rhs.sortOrder
    }

    private var sortOrder: Int {
      switch self {
      case .current: 3
      case .deprecated: 2
      case .sunset: 1
      case .endOfLife: 0
      }
    }
  }

  public var type: ProfileType
  public var status: Status
  public var version: String

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case type = "profile"
    case status
    case version
  }

}
