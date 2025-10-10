#if DEBUG
import Foundation
@testable import BITTestingCore

extension EIDRequestErrorResponse: Mockable {
  struct Mock {
    static let clientAttestationSample: EIDRequestErrorResponse = Mocker.decode(fromFile: "eid-request-client-attestation-error-response", bundle: Bundle.module)
    static let keyAttestationSample: EIDRequestErrorResponse = Mocker.decode(fromFile: "eid-request-key-attestation-error-response", bundle: Bundle.module)
    static let insuffisanceResistanceSample: EIDRequestErrorResponse = Mocker.decode(fromFile: "eid-request-insuffisant-resistance-error-response", bundle: Bundle.module)
    static let legalRepresentantNotRequiredSample: EIDRequestErrorResponse = Mocker.decode(fromFile: "eid-request-legal-representant-not-required-error-response", bundle: Bundle.module)
  }
}
#endif
