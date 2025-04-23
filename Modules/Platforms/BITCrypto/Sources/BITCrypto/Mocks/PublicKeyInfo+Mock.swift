#if DEBUG
import Foundation
@testable import BITTestingCore

// MARK: - PublicKeyInfo + Mockable

extension PublicKeyInfo: Mockable {
  struct Mock {
    static let sample: PublicKeyInfo = Mocker.decode(fromFile: "jwks", bundle: Bundle.module)
    static let sampleData: Data = Mocker.getData(fromFile: "jwks", bundle: Bundle.module) ?? Data()
    static let samplesMultiple: PublicKeyInfo = Mocker.decode(fromFile: "jwks-multiple", bundle: Bundle.module)
  }
}

// MARK: - PublicKeyInfo.JWK + Mockable

extension PublicKeyInfo.JWK: Mockable {
  struct Mock {
    static let validSample: PublicKeyInfo.JWK = Mocker.decode(fromFile: "valid-jwk", bundle: Bundle.module)
    static let invalidSample: PublicKeyInfo.JWK = Mocker.decode(fromFile: "invalid-jwk", bundle: Bundle.module)
  }
}
#endif
