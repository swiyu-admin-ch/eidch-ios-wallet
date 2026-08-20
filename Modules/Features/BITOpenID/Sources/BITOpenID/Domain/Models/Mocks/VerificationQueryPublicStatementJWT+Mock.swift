#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT

// MARK: VerificationQueryPublicStatementJWT.Mock

extension VerificationQueryPublicStatementJWT: Mockable {
  struct Mock {
    static let validSampleData: Data = Mocker.getData(fromFile: "vqPS-valid-sample", bundle: Bundle.module) ?? Data()
    static let wrongVerificationTypeData: Data = Mocker.getData(fromFile: "vqPS-wrong-verification-type", bundle: Bundle.module) ?? Data()
  }
}
#endif
