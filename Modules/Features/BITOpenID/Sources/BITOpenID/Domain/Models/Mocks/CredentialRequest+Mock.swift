#if DEBUG
import Foundation
@testable import BITCore

// MARK: CredentialRequest.Mock

extension CredentialRequest: Mockable {

  struct Mock {
    static let sampleData: Data = Mocker.getData(fromFile: "credential-request-body", bundle: Bundle.module) ?? Data()
    static let sample: CredentialRequest = Mocker.decode(fromFile: "credential-request-body", bundle: Bundle.module)
  }

}
#endif
