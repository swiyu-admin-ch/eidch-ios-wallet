#if DEBUG
import Foundation
@testable import BITTestingCore

extension ValidateAttestationsRequestBody: Mockable {
  struct Mock {
    static let sample: ValidateAttestationsRequestBody = Mocker.decode(fromFile: "validate-attestations-request-body", bundle: Bundle.module)
  }
}
#endif
