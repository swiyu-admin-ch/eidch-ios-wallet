import Foundation

// MARK: - ActivityDetail

public struct ActivityDetail: Identifiable, Codable, Equatable {

  // MARK: Public

  public let id: UUID
  public let type: ActivityType
  public let createdAt: Date
  public let actorDisplay: ActivityActorDisplay?
  public let actorTrust: ActorTrust
  public let vcSchemaTrust: VcSchemaTrust
  public let actorCompliance: ActorComplianceStatus
  public let nonComplianceReasonDisplay: NonComplianceReasonDisplay?
  public let credential: ActivityDetailCredential
}
