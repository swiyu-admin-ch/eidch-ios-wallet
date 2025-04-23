#if DEBUG
import Foundation
@testable import BITJWT
@testable import BITTestingCore

extension JWTProofPayload: Mockable {
  struct Mock {
    static let sample: JWS<JWTProofPayload> = encodePayload(fromFile: "jwt-payload")

    private static func encodePayload(fromFile filename: String) -> JWS<JWTProofPayload> {
      let header = JWSHeader(algorithm: JWTAlgorithm.ES256)
      let payload: JWTProofPayload = decode(fromFile: filename, bundle: Bundle.module)
      return JWS(payload: payload, rawJWS: "rawJWS", rawPayload: "rawPayload", header: header)
    }
  }
}
#endif
