#if DEBUG
import Foundation
@testable import BITCore

// MARK: AccessToken.Mock

extension CredentialResponseError: Mockable {
  struct Mock {
    static let sampleRequestDeniedData: Data = Mocker.getData(fromFile: "credential-response-error-request-denied", bundle: Bundle.module) ?? Data()
    static let sampleInvalidAccessTokenData: Data = Mocker.getData(fromFile: "credential-response-error-invalid-access-token", bundle: Bundle.module) ?? Data()
  }
}
#endif
