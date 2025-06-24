#if DEBUG
import Foundation
@testable import BITTestingCore

extension KeyAttestationRequestBody: Mockable {
  struct Mock {
    static let sample: KeyAttestationRequestBody = decode(fromFile: "key-attestation-request-body", bundle: Bundle.module)
  }
}
#endif
