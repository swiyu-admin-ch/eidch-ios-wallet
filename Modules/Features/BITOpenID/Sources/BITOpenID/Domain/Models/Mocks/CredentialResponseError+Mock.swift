#if DEBUG
import Foundation
@testable import BITTestingCore

// MARK: AccessToken.Mock

extension CredentialResponseError: Mockable {
  struct Mock {
    static let sample: CredentialResponseError = Mocker.decode(fromFile: "credential-response-error", bundle: Bundle.module)
    static let sampleData: Data = Mocker.getData(fromFile: "credential-response-error", bundle: Bundle.module) ?? Data()
  }
}
#endif
