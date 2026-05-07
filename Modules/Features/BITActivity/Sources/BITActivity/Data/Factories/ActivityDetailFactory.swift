import BITEntities
import Factory
import Foundation
import Spyable

// MARK: - ActivityDetailFactoryProtocol

@Spyable
public protocol ActivityDetailFactoryProtocol {
  func callAsFunction(_ entity: CredentialActivityEntity) throws -> ActivityDetail
}

// MARK: - ActivityDetailFactory

struct ActivityDetailFactory: ActivityDetailFactoryProtocol {

  // MARK: Internal

  func callAsFunction(_ entity: CredentialActivityEntity) throws -> ActivityDetail {
    guard let credential = entity.credential.first else {
      throw ActivityDetailFactoryError.noCredentialFound
    }
    return ActivityDetail(
      id: entity.id,
      type: ActivityType(rawValue: entity.type) ?? .issuance,
      createdAt: entity.createdAt,
      actorDisplay: entity.actorDisplays.findDisplayWithFallback().flatMap(activityActorDisplayFactory.callAsFunction),
      actorTrust: ActorTrust(rawValue: entity.actorTrust) ?? .unknown,
      vcSchemaTrust: VcSchemaTrust(rawValue: entity.vcSchemaTrust) ?? .notProtected,
      actorCompliance: ActorComplianceStatus(rawValue: entity.actorCompliance) ?? .unknown,
      nonComplianceReasonDisplay: entity.nonComplianceReasonDisplays.findDisplayWithFallback().flatMap(nonComplianceReasonDisplayFactory.callAsFunction),
      credential: activityDetailCredentialFactory(credential, claimIds: entity.claims.map(\.credentialClaimId)))
  }

  // MARK: Private

  @Injected(\.activityDetailCredentialFactory) private var activityDetailCredentialFactory
  @Injected(\.activityActorDisplayFactory) private var activityActorDisplayFactory
  @Injected(\.nonComplianceReasonDisplayFactory) private var nonComplianceReasonDisplayFactory
}

// MARK: - ActivityDetailFactoryError

enum ActivityDetailFactoryError: Error {
  case noCredentialFound
}
