#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT

// swiftlint: disable force_try

extension RequestObjectJWS: Mockable {
  public struct Mock {
    private static let jwsHeader = JWSHeader(algorithm: JWTAlgorithm.ES256)
    public static let sample: RequestObjectJWS = createObject(header: jwsHeader)
    public static let sampleData: Data = getData(fromFile: "jwt-request-object-sample", ofType: "txt", bundle: Bundle.module) ?? Data()
    public static let sampleJWT: RequestObjectJWT = decode(fromFile: "jwt-request-object-payload-sample", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    static let noVctPayload: RequestObjectJWT = decode(fromFile: "jwt-request-object-payload-no-vct", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    static let clientIdMismatchPayload: RequestObjectJWT = decode(fromFile: "jwt-request-object-client-id-mismatch", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    static let noVct: RequestObjectJWS = createObject(header: jwsHeader, payload: noVctPayload)
    static let clientIdMismatch: RequestObjectJWS = createObject(header: jwsHeader, payload: clientIdMismatchPayload)
    static let unsupportedAlgorithm: RequestObjectJWS = createObject(header: JWSHeader(algorithm: JWTAlgorithm.ES384))

    private static func createObject(header: JWSHeader, payload: RequestObjectJWT = sampleJWT) -> RequestObjectJWS {
      JWS(payload: payload, rawPayload: "{\"iss\":\"issuer\"}", rawJWS: "rawJWS", header: header)
    }
  }
}
// swiftlint: enable all
#endif
