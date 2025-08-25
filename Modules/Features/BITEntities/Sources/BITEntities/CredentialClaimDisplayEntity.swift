import Foundation
import RealmSwift

// MARK: - CredentialClaimDisplayEntity

public class CredentialClaimDisplayEntity: Object {
  @Persisted(primaryKey: true) public var id: UUID
  @Persisted public var locale: String
  @Persisted public var name: String?
  @Persisted public var value: String?
}
