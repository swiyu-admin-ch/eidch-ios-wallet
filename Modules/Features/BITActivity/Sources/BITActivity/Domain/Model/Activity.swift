import BITCredentialShared
import BITEntities
import Foundation

// MARK: - Activity

public struct Activity: Identifiable, Codable {

  // MARK: Lifecycle

  public init(
    id: UUID = UUID(),
    credential: VerifiableCredential? = nil,
    type: ActivityType,
    createdAt: Date = Date(),
    actorTrust: ActorTrust,
    vcSchemaTrust: VcSchemaTrust,
    nonComplianceData: String? = nil,
    claims: [ActivityClaim] = [],
    actorDisplays: [ActivityActorDisplay] = [])
  {
    self.id = id
    self.credential = credential
    self.type = type
    self.createdAt = createdAt
    self.actorTrust = actorTrust
    self.vcSchemaTrust = vcSchemaTrust
    self.nonComplianceData = nonComplianceData
    self.claims = claims
    self.actorDisplays = actorDisplays
  }

  public init(_ entity: CredentialActivityEntity) {
    var credential: VerifiableCredential?
    if let credentialEntity = entity.credential.first {
      credential = try? VerifiableCredential(credentialEntity)
    }
    self.init(
      id: entity.id,
      credential: credential,
      type: ActivityType(rawValue: entity.type) ?? .issuance,
      createdAt: entity.createdAt,
      actorTrust: ActorTrust(rawValue: entity.actorTrust) ?? .unknown,
      vcSchemaTrust: VcSchemaTrust(rawValue: entity.vcSchemaTrust) ?? .notProtected,
      nonComplianceData: entity.nonComplianceData,
      claims: Array(entity.claims.map(ActivityClaim.init)),
      actorDisplays: Array(entity.actorDisplays.map(ActivityActorDisplay.init)))
  }

  // MARK: Public

  public var id: UUID
  public var credential: VerifiableCredential?
  public var type: ActivityType
  public var createdAt: Date
  public var actorTrust: ActorTrust
  public var vcSchemaTrust: VcSchemaTrust
  public var nonComplianceData: String?
  public var claims: [ActivityClaim]
  public var actorDisplays: [ActivityActorDisplay]
}

// MARK: - ActivityType

public enum ActivityType: String, Codable {
  case presentationAccepted
  case presentationDeclined
  case issuance
}

// MARK: - CredentialActivityError

public enum CredentialActivityError: Error {
  case invalidEntity
}

// MARK: - Activity + Equatable

extension Activity: Equatable {

  public static func == (lhs: Activity, rhs: Activity) -> Bool {
    lhs.id == rhs.id &&
      lhs.credential == rhs.credential &&
      lhs.type == rhs.type &&
      lhs.createdAt == rhs.createdAt &&
      lhs.actorTrust == rhs.actorTrust &&
      lhs.vcSchemaTrust == rhs.vcSchemaTrust &&
      lhs.nonComplianceData == rhs.nonComplianceData &&
      lhs.claims.allSatisfy(rhs.claims.contains) && rhs.claims.allSatisfy(lhs.claims.contains) &&
      lhs.actorDisplays.allSatisfy(rhs.actorDisplays.contains) && rhs.actorDisplays.allSatisfy(lhs.actorDisplays.contains)
  }

}

// MARK: - Activity + Hashable

extension Activity: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
