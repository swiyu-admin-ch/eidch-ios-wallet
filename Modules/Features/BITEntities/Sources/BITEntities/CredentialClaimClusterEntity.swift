import Foundation
import RealmSwift

// MARK: - CredentialClaimClusterEntity

public class CredentialClaimClusterEntity: Object {
  @Persisted(primaryKey: true) public var id: UUID
  @Persisted public var order: Int16
  @Persisted public var claims: List<CredentialClaimEntity>
  @Persisted public var childClusters: List<CredentialClaimClusterEntity>
  @Persisted public var displays = List<CredentialClaimClusterDisplayEntity>()
}
