import Foundation
import RealmSwift

public class EIDRequestCaseFileEntity: Object {
  @Persisted(primaryKey: true) public var id: UUID
  @Persisted public var fileName: String
  @Persisted public var mime: String
  @Persisted public var data: Data
  @Persisted public var category: String

  @Persisted public var createdAt = Date()

  @Persisted(originProperty: "files")
  public var requestCase: LinkingObjects<EIDRequestCaseEntity>

}
