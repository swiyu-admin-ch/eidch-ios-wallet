import Foundation
import RealmSwift

public class CredentialEntity: Object {

  @Persisted(primaryKey: true) public var id: UUID
  @Persisted public var format: String
  @Persisted public var issuerUrl: String
  @Persisted public var selectedConfigurationId: String?
  @Persisted public var createdAt = Date()

  @Persisted public var eIDRequestCase: EIDRequestCaseEntity?
  @Persisted public var rawCredentialData: RawCredentialDataEntity?
  // 1-1 relationship, but realm requires this to be marked as optional.
  @Persisted public var authentication: CredentialAuthenticationEntity?
  @Persisted public var deferredCredential: DeferredCredentialEntity?
  @Persisted public var verifiableCredential: VerifiableCredentialEntity?

  @Persisted public var issuerDisplays = List<CredentialIssuerDisplayEntity>()
  @Persisted public var displays = List<CredentialDisplayEntity>()
  @Persisted public var activities = List<CredentialActivityEntity>()

}
