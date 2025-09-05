#if DEBUG
import Foundation
@testable import BITTestingCore

extension EIDRequestErrorResponse: Mockable {
  struct Mock {
    static let clientAttestationSample: EIDRequestErrorResponse = Mocker.decode(fromFile: "validate-attestation-client-attestation-error-response", bundle: Bundle.module)
    static let keyAttestationSample: EIDRequestErrorResponse = Mocker.decode(fromFile: "validate-attestation-key-attestation-error-response", bundle: Bundle.module)
    static let insuffisanceResistanceSample: EIDRequestErrorResponse = Mocker.decode(fromFile: "validate-attestation-insuffisant-resistance-error-response", bundle: Bundle.module)
  }
}
#endif
