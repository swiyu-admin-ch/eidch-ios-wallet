#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT

extension ProofJWT: Mockable {
  struct Mock {
    static let sample: JWS<ProofJWT> = encodePayload(fromFile: "jwt-payload")

    private static func encodePayload(fromFile filename: String) -> JWS<ProofJWT> {
      let header = JWSHeader(algorithm: JWTAlgorithm.ES256)
      let payload: ProofJWT = decode(fromFile: filename, dateFormatter: .millisecondsSince1970, bundle: Bundle.module)
      return JWS(payload: payload, rawPayload: "rawPayload", rawJWS: "rawJWS", header: header)
    }
  }
}
#endif
