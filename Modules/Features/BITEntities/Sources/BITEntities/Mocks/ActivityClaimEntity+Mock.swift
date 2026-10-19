#if DEBUG
import Foundation
@testable import BITCore

extension ActivityClaimEntity: Mockable {
  public struct Mock {
    public static func create(path: String = "[\"key\"]", createParent: Bool = true) throws -> ActivityClaimEntity {
      let entity = ActivityClaimEntity()
      entity.path = path

      if createParent {
        _ = try CredentialActivityEntity.Mock.create(claims: [entity])
      }
      return entity
    }
  }
}
#endif
