#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT

extension DPoPJWT {
  struct Mock {

    // MARK: Internal

    static let sample: DPoP = decodeDPoP(from: "dpop-sample")

    // MARK: Private

    private static func decodeDPoP(from file: String, type: String = "dpop+jwt", bundle: Bundle = Bundle.module) -> DPoP {
      let jwt: DPoPJWT = Mocker.decode(fromFile: file, dateFormatter: .secondsSince1970, bundle: bundle)
      let header = JWSHeader(algorithm: .ES256, type: type)
      return DPoP(payload: jwt, rawPayload: "", rawJWS: "proof", header: header)
    }
  }
}
#endif
