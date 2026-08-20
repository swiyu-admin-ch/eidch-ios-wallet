import Foundation
import RealmSwift

public class CredentialIssuerDisplayEntity: Object {

  @Persisted(primaryKey: true) public var id: UUID
  @Persisted public var locale: String?
  @Persisted public var name: String?
  @Persisted public var imageHash: String?
  @Persisted public var image: Data?

  @Persisted(originProperty: "issuerDisplays")
  public var credential: LinkingObjects<CredentialEntity>

  public var cachedImage: Data? {
    guard let imageHash, let realm else {
      return image
    }

    return realm.object(ofType: ImageEntity.self, forPrimaryKey: imageHash)?.data ?? image
  }

}
