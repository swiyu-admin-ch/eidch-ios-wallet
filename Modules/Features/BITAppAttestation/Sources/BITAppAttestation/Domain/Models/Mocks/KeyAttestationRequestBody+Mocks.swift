#if DEBUG
import Foundation
@testable import BITCore

extension KeyAttestationRequestBody: Mockable {
  struct Mock {
    static let sample: KeyAttestationRequestBody = decode(fromFile: "key-attestation-request-body", bundle: Bundle.module)
  }
}
#endif
