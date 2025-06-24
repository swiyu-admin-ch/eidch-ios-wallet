#if DEBUG
import Foundation
@testable import BITTestingCore

extension AttestationChallenge.Response: Mockable {
  struct Mock {
    static let sample: AttestationChallenge.Response = decode(fromFile: "challenge-response", bundle: Bundle.module)
    static let sampleData: Data = getData(fromFile: "challenge-response", bundle: Bundle.module) ?? Data()
  }
}
#endif
