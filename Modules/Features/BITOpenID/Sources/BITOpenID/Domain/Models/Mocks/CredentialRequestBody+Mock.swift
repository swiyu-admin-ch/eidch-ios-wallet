#if DEBUG
import Foundation
@testable import BITTestingCore

// MARK: CredentialRequestBody.Mock

extension VcSdJwtCredentialRequestBody: Mockable {

  struct Mock {
    static let sampleData: Data = Mocker.getData(fromFile: "credential-request-body", bundle: Bundle.module) ?? Data()
    static let sample: VcSdJwtCredentialRequestBody = Mocker.decode(fromFile: "credential-request-body", bundle: Bundle.module)
  }

}
#endif
