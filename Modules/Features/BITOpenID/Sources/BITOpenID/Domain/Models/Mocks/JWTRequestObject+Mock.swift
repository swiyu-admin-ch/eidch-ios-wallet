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
    static let noVctPayload: JWTRequestObjectPayload = decode(fromFile: "jwt-request-object-payload-no-vct", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    static let clientIdMismatchPayload: JWTRequestObjectPayload = decode(fromFile: "jwt-request-object-client-id-mismatch", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    static let noVct: JWTRequestObject = createObject(header: jwsHeader, payload: noVctPayload)
    static let clientIdMismatch: JWTRequestObject = createObject(header: jwsHeader, payload: clientIdMismatchPayload)
    static let unsupportedAlgorithm: JWTRequestObject = createObject(header: JWSHeader(algorithm: JWTAlgorithm.ES384))

    private static func createObject(header: JWSHeader, payload: JWTRequestObjectPayload = samplePayload) -> JWTRequestObject {
      JWS(payload: payload, rawPayload: "{\"iss\":\"issuer\"}", rawJWS: "rawJWS", header: header)
    }
  }
}
// swiftlint: enable all
#endif
