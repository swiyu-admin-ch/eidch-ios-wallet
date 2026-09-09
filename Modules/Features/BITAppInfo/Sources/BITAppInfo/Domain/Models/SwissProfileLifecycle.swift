import Foundation

public struct SwissProfile: Codable {

  // MARK: Public

  public enum ProfileType: String, Codable, CaseIterable {
    case anchor = "swiss-profile-anchor"
    case issuance = "swiss-profile-issuance"
    case portability = "swiss-profile-portability"
    case proximity = "swiss-profile-proximity"
    case trust = "swiss-profile-trust"
    case verifiableCredential = "swiss-profile-vc"
    case verification = "swiss-profile-verification"
  }

  public enum Status: String, Codable {
    case current
    case deprecated
    case sunset
    case endOfLife = "eol"
  }

  public let type: ProfileType
  public let status: Status
  public let version: String

  // MARK: Private

  private enum CodingKeys: String, CodingKey {
    case type = "profile"
    case status
    case version
  }

}
