#if DEBUG
import Foundation
@testable import BITTestingCore

extension ValidateAttestationsErrorResponse: Mockable {
  struct Mock {
    static let clientAttestationSample: ValidateAttestationsErrorResponse = Mocker.decode(fromFile: "validate-attestation-client-attestation-error-response", bundle: Bundle.module)
    static let keyAttestationSample: ValidateAttestationsErrorResponse = Mocker.decode(fromFile: "validate-attestation-key-attestation-error-response", bundle: Bundle.module)
    static let insuffisanceResistanceSample: ValidateAttestationsErrorResponse = Mocker.decode(fromFile: "validate-attestation-insuffisant-resistance-error-response", bundle: Bundle.module)
  }
}
#endif
