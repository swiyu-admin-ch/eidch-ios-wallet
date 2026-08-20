import Foundation
import RealmSwift

public class EIDRequestCaseWalletEntity: Object {
  @Persisted(primaryKey: true) public var id: UUID
  @Persisted public var pairingId: String
  @Persisted public var createdAt = Date()

  @Persisted(originProperty: "pairingIds")
  public var requestCase: LinkingObjects<EIDRequestCaseEntity>
}
