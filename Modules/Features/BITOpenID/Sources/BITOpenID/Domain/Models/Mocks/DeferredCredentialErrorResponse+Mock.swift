#if DEBUG
import Foundation
@testable import BITTestingCore

// MARK: AccessToken.Mock

extension DeferredCredentialErrorResponse: Mockable {
  struct Mock {
    static let sample: DeferredCredentialErrorResponse = Mocker.decode(fromFile: "deferred-credential-error-response", bundle: Bundle.module)
    static let sampleData: Data = Mocker.getData(fromFile: "deferred-credential-error-response", bundle: Bundle.module) ?? Data()
  }
}
#endif
