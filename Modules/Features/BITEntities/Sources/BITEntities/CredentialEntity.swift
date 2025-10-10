import Foundation
import RealmSwift

public class CredentialEntity: Object {

  @Persisted(primaryKey: true) public var id: UUID
  @Persisted public var format: String
  @Persisted public var createdAt = Date()

  @Persisted public var eIDRequestCase: EIDRequestCaseEntity?
  @Persisted public var keyBinding: CredentialKeyBindingEntity?
  @Persisted public var rawCredentialData: RawCredentialDataEntity?
  @Persisted public var deferredCredential: DeferredCredentialEntity?
  @Persisted public var verifiableCredential: VerifiableCredentialEntity?

  @Persisted public var issuerDisplays = List<CredentialIssuerDisplayEntity>()
  @Persisted public var displays = List<CredentialDisplayEntity>()

}
