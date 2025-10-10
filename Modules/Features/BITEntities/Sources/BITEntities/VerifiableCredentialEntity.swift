import Foundation
import RealmSwift

public class VerifiableCredentialEntity: Object {

  public enum ProgressionState: String, PersistableEnum {
    case accepted
    case unaccepted
  }

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
  @Persisted public var status: CredentialStatus
  @Persisted public var progressionState: ProgressionState
  @Persisted public var payload: Data
  @Persisted public var issuer: String

  @Persisted public var validFrom: Date?
  @Persisted public var validUntil: Date?

  @Persisted public var createdAt = Date()

  @Persisted public var clusters = List<CredentialClaimClusterEntity>()
}
