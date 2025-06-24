import Foundation
import RealmSwift

// MARK: - CredentialClaimClusterDisplayEntity

public class CredentialClaimClusterDisplayEntity: Object {
  @Persisted(primaryKey: true) public var id: UUID
  @Persisted public var locale: String
  @Persisted public var name: String
}
