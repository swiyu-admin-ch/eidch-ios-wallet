#if DEBUG
import Foundation
@testable import BITTestingCore

// MARK: - CredentialResponse + Mockable

extension CredentialResponse: Mockable {

  struct Mock {
    static let sample: CredentialResponse = Mocker.decode(fromFile: "credential-response", bundle: Bundle.module)
    static let sampleData: Data = Mocker.getData(fromFile: "credential-response", bundle: Bundle.module) ?? Data()
  }
}
#endif
