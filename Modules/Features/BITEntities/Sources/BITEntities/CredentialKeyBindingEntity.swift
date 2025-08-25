import Foundation
import RealmSwift

// MARK: - CredentialKeyBindingEntity

public class CredentialKeyBindingEntity: Object {

  @Persisted(primaryKey: true) public var id: UUID
  @Persisted public var algorithm: String
  @Persisted public var bindingType: String
  @Persisted public var publicKey: Data?
  @Persisted public var privateKey: Data?
}
