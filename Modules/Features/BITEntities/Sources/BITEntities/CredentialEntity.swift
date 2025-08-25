import Foundation
import RealmSwift

// MARK: - CredentialEntity

public class CredentialEntity: Object {

  @Persisted(primaryKey: true) public var id: UUID
  @Persisted public var status: String
  @Persisted public var keyBinding: CredentialKeyBindingEntity?
  @Persisted public var payload: Data
  @Persisted public var rawCredentialData: RawCredentialDataEntity?
  @Persisted public var format: String
  @Persisted public var issuer: String
  @Persisted public var validFrom: Date?
  @Persisted public var validUntil: Date?

  @Persisted public var createdAt = Date()
  @Persisted public var updatedAt: Date?

  @Persisted public var clusters = List<CredentialClaimClusterEntity>()
  @Persisted public var issuerDisplays = List<CredentialIssuerDisplayEntity>()
  @Persisted public var displays = List<CredentialDisplayEntity>()

}
