#if DEBUG
import Foundation
@testable import BITJWT
@testable import BITTestingCore

// swiftlint: disable force_try

extension JWTRequestObjectPayload: Mockable {
  struct Mock {
    private static let jwsHeader = JWSHeader(algorithm: JWTAlgorithm.ES256)
    static let sample: JWTRequestObject = createObject(header: jwsHeader)
    static let sampleData: Data = getData(fromFile: "jwt-request-object-sample", ofType: "txt", bundle: Bundle.module) ?? Data()
    static let samplePayload: JWTRequestObjectPayload = decode(fromFile: "jwt-request-object-payload-sample", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    static let unsupportedAlgorithm: JWTRequestObject = createObject(header: JWSHeader(algorithm: JWTAlgorithm.ES384))

    private static func createObject(header: JWSHeader) -> JWTRequestObject {
      JWS(payload: samplePayload, rawPayload: "{\"iss\":\"issuer\"}", rawJWS: "rawJWS", header: header)
    }
  }
}
// swiftlint: enable all
#endif
