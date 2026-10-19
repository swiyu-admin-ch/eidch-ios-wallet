#if DEBUG
import Foundation
import RealmSwift
@testable import BITCore

extension VerifiableCredentialEntity: Mockable {
  public struct Mock {
    public static func create(issuer: String = "issuer", createParent: Bool = true) throws -> VerifiableCredentialEntity {
      let entity = VerifiableCredentialEntity()
      entity.issuer = issuer

      try Realm.save(entity)
      if createParent {
        _ = try CredentialEntity.Mock.create(verifiableCredential: entity)
      }
      return entity
    }
  }
}
#endif
