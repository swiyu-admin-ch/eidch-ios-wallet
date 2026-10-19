import Foundation
import RealmSwift

// MARK: - RawCredentialDataEntity

public class RawCredentialDataEntity: Object, ContentHashedEntity {

  @Persisted(primaryKey: true) public var contentHash: String
  @Persisted public var rawOIDMetadata: Data?
  @Persisted public var rawOcaBundle: Data?
}
