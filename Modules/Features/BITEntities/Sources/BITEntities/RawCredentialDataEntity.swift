import Foundation
import RealmSwift

// MARK: - RawCredentialDataEntity

public class RawCredentialDataEntity: Object {

  @Persisted(primaryKey: true) public var id: UUID
  @Persisted public var rawOIDMetadata: Data?
  @Persisted public var rawOcaBundle: Data?
}
