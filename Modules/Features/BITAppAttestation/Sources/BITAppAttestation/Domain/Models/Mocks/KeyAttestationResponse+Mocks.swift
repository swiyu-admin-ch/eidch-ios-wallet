#if DEBUG
import Foundation
@testable import BITTestingCore

extension KeyAttestationResponse: Mockable {
  struct Mock {
    static let sample: KeyAttestationResponse = decode(fromFile: "key-attestation-response", bundle: Bundle.module)
    static let sampleData: Data = getData(fromFile: "key-attestation-response", bundle: Bundle.module) ?? Data()
  }
}
#endif
