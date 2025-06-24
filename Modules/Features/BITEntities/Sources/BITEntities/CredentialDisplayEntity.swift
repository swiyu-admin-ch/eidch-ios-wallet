import Foundation
import RealmSwift

// MARK: - CredentialDisplayEntity

public class CredentialDisplayEntity: Object {

  @Persisted(primaryKey: true) public var id: UUID
  @Persisted public var name: String?
  @Persisted public var locale: String?
  @Persisted public var logoAltText: String?
  @Persisted public var logoData: Data?
  @Persisted public var summary: String?
  @Persisted public var backgroundColor: String?
  @Persisted public var theme: String?
  @Persisted(originProperty: "displays")
  public var credential: LinkingObjects<CredentialEntity>

}
