import Foundation
import RealmSwift

public class BundleItemEntity: Object {

  public enum CredentialStatus: String, PersistableEnum {
    case valid
    case revoked
    case suspended
    case expired
    case notYetValid
    case unsupported
    case unknown
  }

  @Persisted(primaryKey: true) public var id: UUID
  @Persisted public var payload: Data
  @Persisted public var status: CredentialStatus
  @Persisted public var presented = false
  @Persisted public var keyBinding: CredentialKeyBindingEntity?
}
