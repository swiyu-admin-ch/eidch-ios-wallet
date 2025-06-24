#if DEBUG
import Foundation
@testable import BITTestingCore

extension JWK: Mockable {
  struct Mock {
    static let validSample: JWK = Mocker.decode(fromFile: "valid-jwk", bundle: Bundle.module)
    static let invalidSample: JWK = Mocker.decode(fromFile: "invalid-jwk", bundle: Bundle.module)
  }
}
#endif
