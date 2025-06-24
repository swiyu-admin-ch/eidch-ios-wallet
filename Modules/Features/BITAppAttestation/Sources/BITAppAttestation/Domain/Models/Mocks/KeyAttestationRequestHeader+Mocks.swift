#if DEBUG
import Foundation
@testable import BITTestingCore

extension KeyAttestationRequestHeader: Mockable {
  struct Mock {
    static let sample: KeyAttestationRequestHeader = decode(fromFile: "key-attestation-request-header", bundle: Bundle.module)
  }
}
#endif
