import Foundation
import RealmSwift

public class ActivityBundleItemEntity: EmbeddedObject {

  @Persisted public var payload: Data?
  @Persisted public var statusListState: BundleItemEntity.CredentialStatus
}
