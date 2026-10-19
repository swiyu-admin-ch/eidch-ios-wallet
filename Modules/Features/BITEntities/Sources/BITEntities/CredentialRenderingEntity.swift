import Foundation
import RealmSwift

// MARK: - CredentialRenderingEntity

public class CredentialRenderingEntity: Object, ContentHashedEntity {

  @Persisted(primaryKey: true) public var contentHash: String
  @Persisted public var createdAt = Date()

  @Persisted public var displays = List<CredentialDisplayEntity>()
  @Persisted public var issuerDisplays = List<CredentialIssuerDisplayEntity>()
  @Persisted public var clusters = List<CredentialClaimClusterEntity>()
}
