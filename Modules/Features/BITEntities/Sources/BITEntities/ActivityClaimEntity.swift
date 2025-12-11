import Foundation
import RealmSwift

public class ActivityClaimEntity: EmbeddedObject {

  @Persisted public var credentialClaimId: UUID
}
