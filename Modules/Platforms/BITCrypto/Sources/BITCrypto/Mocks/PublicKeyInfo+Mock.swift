#if DEBUG
import Foundation
@testable import BITTestingCore

extension PublicKeyInfo: Mockable {
  struct Mock {
    static let sample: PublicKeyInfo = Mocker.decode(fromFile: "jwks", bundle: Bundle.module)
    static let sampleData: Data = Mocker.getData(fromFile: "jwks", bundle: Bundle.module) ?? Data()
    static let samplesMultiple: PublicKeyInfo = Mocker.decode(fromFile: "jwks-multiple", bundle: Bundle.module)
  }
}
#endif
