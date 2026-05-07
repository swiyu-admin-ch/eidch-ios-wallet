import Foundation
import RealmSwift

// MARK: - CredentialAuthenticationEntity

public class CredentialAuthenticationEntity: EmbeddedObject {
  @Persisted public var tokenType: String
  @Persisted public var accessToken: String
  @Persisted public var refreshToken: String?
  @Persisted public var dpopBinding: DPoPBindingEntity?
}
