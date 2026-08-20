#if DEBUG
import BITCore
import Foundation

extension CredentialPayload: Mockable {
  struct Mock {
    static let `default`: CredentialPayload = .getData(fromFile: "raw-credential-jwt", ofType: "txt", bundle: .module) ?? Data()
    static let noKeyBinding: CredentialPayload = .getData(fromFile: "raw-credential-jwt-no-key-binding", ofType: "txt", bundle: .module) ?? Data()
  }
}
#endif
