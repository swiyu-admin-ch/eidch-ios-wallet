import Foundation
import RealmSwift

public class ClientAttestationEntity: Object {

  @Persisted(primaryKey: true) public var id: UUID
  @Persisted public var attestation: String
  @Persisted public var createdAt = Date()
}
