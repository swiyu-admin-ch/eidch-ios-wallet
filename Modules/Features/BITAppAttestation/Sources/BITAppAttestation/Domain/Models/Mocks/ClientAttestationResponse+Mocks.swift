#if DEBUG
import Foundation
@testable import BITTestingCore

extension ClientAttestationResponse: Mockable {
  struct Mock {
    static let sample: ClientAttestationResponse = decode(fromFile: "client-attestation-response", bundle: Bundle.module)
    static let sampleData: Data = getData(fromFile: "client-attestation-response", bundle: Bundle.module) ?? Data()
  }
}
#endif
