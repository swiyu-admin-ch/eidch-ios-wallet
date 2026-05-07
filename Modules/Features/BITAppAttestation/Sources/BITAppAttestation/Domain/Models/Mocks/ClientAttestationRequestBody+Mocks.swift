#if DEBUG
import Foundation
@testable import BITCore

extension ClientAttestationRequestBody: Mockable {
  struct Mock {
    static let sample: ClientAttestationRequestBody = decode(fromFile: "client-attestation-request-body", bundle: Bundle.module)
  }
}
#endif
