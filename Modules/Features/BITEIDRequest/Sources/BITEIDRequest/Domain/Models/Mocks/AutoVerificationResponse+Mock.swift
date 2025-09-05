#if DEBUG
import Foundation
@testable import BITTestingCore

extension AutoVerificationResponse: Mockable {
  struct Mock {
    static let nfcSample: AutoVerificationResponse = Mocker.decode(fromFile: "auto-verification-response", bundle: Bundle.module)
    static let noNfcSample: AutoVerificationResponse = Mocker.decode(fromFile: "auto-verification-response-no-nfc", bundle: Bundle.module)
    static let sampleData: Data = Mocker.getData(fromFile: "auto-verification-response", bundle: Bundle.module) ?? Data()
  }
}
#endif
