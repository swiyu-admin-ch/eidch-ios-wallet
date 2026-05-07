import BITCredentialShared
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
    actorCompliance: ActorComplianceStatus = .unknown,
    nonComplianceData: String? = nil,
    nonComplianceReasonDisplays: [NonComplianceReasonDisplay] = [],
    claims: [ActivityClaim] = [],
    actorDisplays: [ActivityActorDisplay] = [])
  {
    self.id = id
    self.credential = credential
    self.type = type
    self.createdAt = createdAt
    self.actorTrust = actorTrust
    self.vcSchemaTrust = vcSchemaTrust
    self.actorCompliance = actorCompliance
    self.nonComplianceData = nonComplianceData
    self.nonComplianceReasonDisplays = nonComplianceReasonDisplays
    self.claims = claims
    self.actorDisplays = actorDisplays
  }

  // MARK: Public

  public var id: UUID
  public var credential: VerifiableCredential?
  public var type: ActivityType
  public var createdAt: Date
  public var actorTrust: ActorTrust
  public var vcSchemaTrust: VcSchemaTrust
  public var actorCompliance: ActorComplianceStatus
  public var nonComplianceData: String?
  public var nonComplianceReasonDisplays: [NonComplianceReasonDisplay]
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
      lhs.actorCompliance == rhs.actorCompliance &&
      lhs.nonComplianceData == rhs.nonComplianceData &&
      lhs.nonComplianceReasonDisplays == rhs.nonComplianceReasonDisplays &&
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
