#if DEBUG
import Foundation
@testable import BITTestingCore

// MARK: - CredentialResponseImmediate + Mockable

extension CredentialResponseImmediate: Mockable {

  struct Mock {
    static let sample: CredentialResponseImmediate = Mocker.decode(fromFile: "credential-response", bundle: Bundle.module)
    static let sampleData: Data = Mocker.getData(fromFile: "credential-response", bundle: Bundle.module) ?? Data()
  }
}
#endif
