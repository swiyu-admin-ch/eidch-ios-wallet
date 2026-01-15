#if DEBUG
import Foundation
@testable import BITTestingCore

// MARK: - CredentialResponseDeferred + Mockable

extension CredentialResponseDeferred: Mockable {

  struct Mock {
    static let sample: CredentialResponseDeferred = Mocker.decode(fromFile: "credential-response-deferred", bundle: Bundle.module)
    static let sampleData: Data = Mocker.getData(fromFile: "credential-response-deferred", bundle: Bundle.module) ?? Data()
  }
}
#endif
