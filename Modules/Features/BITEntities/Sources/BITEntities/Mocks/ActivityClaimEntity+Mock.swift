#if DEBUG
import Foundation
import RealmSwift
@testable import BITCore

extension ActivityClaimEntity: Mockable {
  public struct Mock {
    public static func create(claimId: UUID = UUID(), createParent: Bool = true) throws -> ActivityClaimEntity {
      let entity = ActivityClaimEntity()
      entity.credentialClaimId = claimId

      if createParent {
        _ = try CredentialActivityEntity.Mock.create(claims: [entity])
      }
      return entity
    }
  }
}
#endif
