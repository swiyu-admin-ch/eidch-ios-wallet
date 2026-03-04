#if DEBUG
import Foundation
@testable import BITTestingCore

extension JWK: Mockable {
  public struct Mock {
    public static let validSample: JWK = Mocker.decode(fromFile: "valid-jwk", bundle: Bundle.module)
    public static let invalidSample: JWK = Mocker.decode(fromFile: "invalid-jwk", bundle: Bundle.module)

    public static func build(alg: String = "ECDH-ES", crv: String = "P-256") -> JWK {
      JWK(kty: "EC", kid: "kid", crv: crv, x: "x", y: "y", alg: alg)
    }
  }
}
#endif
