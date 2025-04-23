#if DEBUG
import Foundation
@testable import BITJWT
@testable import BITTestingCore

// swiftlint: disable force_try

extension JWTRequestObject: Mockable {
  struct Mock {
    private static let jwsHeader = JWSHeader(algorithm: JWTAlgorithm.ES256)
    static let sample: JWTRequestObject = createObject(header: jwsHeader)
    static let unsupportedAlgorithm: JWTRequestObject = createObject(header: JWSHeader(algorithm: JWTAlgorithm.ES384))

    private static func createObject(header: JWSHeader) -> JWTRequestObject {
      let jws = JWS(payload: RequestObject.Mock.VcSdJwt.sample, rawJWS: "rawJWS", rawPayload: "{\"iss\":\"issuer\"}", header: header)
      return try! JWTRequestObject(from: jws)
    }
  }
}
// swiftlint: enable all
#endif
