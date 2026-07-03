#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT

extension RequestObjectJWS: Mockable {
  public struct Mock {

    // MARK: Public

    public static let sampleData: Data = getData(fromFile: "request-object-jwt", bundle: Bundle.module) ?? Data()
    public static let withoutClientMetadataData: Data = getData(fromFile: "request-object-jwt-no-client-metadata", bundle: Bundle.module) ?? Data()
    public static let unsupportedClientMetadata: Data = getData(fromFile: "request-object-jwt-unsupported-client-metadata", bundle: Bundle.module) ?? Data()
    public static let withConstraintsData: Data = getData(fromFile: "request-object-jwt-with-constraints", bundle: Bundle.module) ?? Data()

    public static let sampleJWT: RequestObjectJWT = decode(fromFile: "request-object-jwt", dateFormatter: .secondsSince1970, bundle: Bundle.module)

    public static let sample: RequestObjectJWS = createObject(header: jwsHeader)
    public static let clientIdDIDPrefix: RequestObjectJWS = createObject(header: jwsHeader, payload: clientIdDidPrefixPayload)
    public static let kidMismatch: RequestObjectJWS = createObject(header: jwsHeaderDidMismatch, payload: clientIdDidPrefixPayload)
    public static let clientIdNotADid: RequestObjectJWS = createObject(header: jwsHeader, payload: clientIdNotADidPayload)
    public static let identityTrust: RequestObjectJWS = createObject(header: jwsHeader, payload: identityTrustPayload)
    public static let unsupportedResponseType: RequestObjectJWS = createObject(header: jwsHeader, payload: unsupportedResponseTypePayload)
    public static let unsupportedClientId: RequestObjectJWS = createObject(header: jwsHeader, payload: unsupportedClientIdPayload)
    public static let transactionData: RequestObjectJWS = createObject(header: jwsHeader, payload: transactionDataPayload)
    public static let missingState: RequestObjectJWS = createObject(header: jwsHeader, payload: missingStatePayload)
    public static let missingDcqlQuery: RequestObjectJWS = createObject(header: jwsHeader, payload: missingDcqlQueryPayload)
    public static let noVct: RequestObjectJWS = createObject(header: jwsHeader, payload: noVctPayload)
    public static let clientIdMismatch: RequestObjectJWS = createObject(header: jwsHeader, payload: clientIdMismatchPayload)
    public static let unsupportedAlgorithm: RequestObjectJWS = createObject(header: JWSHeader(algorithm: JWTAlgorithm.ES384))
    public static let audienceIssuerMismatch: RequestObjectJWS = createObject(header: jwsHeader, payload: audienceIssuerMismatchPayload)
    public static let noAudience: RequestObjectJWS = createObject(header: jwsHeader, payload: noAudiencePayload)

    // MARK: Private

    private static let clientIdMismatchPayload: RequestObjectJWT = Mocker.decode(fromFile: "request-object-jwt-client-id-mismatch", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    private static let noVctPayload: RequestObjectJWT = Mocker.decode(fromFile: "request-object-jwt-no-vct", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    private static let identityTrustPayload: RequestObjectJWT = Mocker.decode(fromFile: "request-object-jwt-identity-trust", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    private static let clientIdDidPrefixPayload: RequestObjectJWT = decode(fromFile: "request-object-jwt-did-prefix", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    private static let clientIdNotADidPayload: RequestObjectJWT = decode(fromFile: "request-object-jwt-client-id-not-a-did", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    private static let unsupportedResponseTypePayload: RequestObjectJWT = decode(fromFile: "request-object-jwt-unsupported-response-type", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    private static let unsupportedClientIdPayload: RequestObjectJWT = decode(fromFile: "request-object-jwt-with-unsupported-client-id", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    private static let transactionDataPayload: RequestObjectJWT = decode(fromFile: "request-object-jwt-with-transaction-data", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    private static let missingStatePayload: RequestObjectJWT = decode(fromFile: "request-object-jwt-missing-state", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    private static let missingDcqlQueryPayload: RequestObjectJWT = decode(fromFile: "request-object-jwt-missing-dcql-query", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    private static let audienceIssuerMismatchPayload: RequestObjectJWT = decode(fromFile: "request-object-jwt-audience-mismatch", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    private static let noAudiencePayload: RequestObjectJWT = decode(fromFile: "request-object-jwt-no-audience", dateFormatter: .secondsSince1970, bundle: Bundle.module)

    private static let jwsHeader = JWSHeader(algorithm: JWTAlgorithm.ES256, type: "oauth-authz-req+jwt", keyIdentifier: "did:example:12345#key-1")
    private static let jwsHeaderDidMismatch = JWSHeader(algorithm: JWTAlgorithm.ES256, keyIdentifier: "did:example:mismatch#key-1")

    private static func createObject(header: JWSHeader, payload: RequestObjectJWT = sampleJWT) -> RequestObjectJWS {
      JWS(payload: payload, rawPayload: "{\"iss\":\"issuer\"}", rawJWS: "rawJWS", header: header)
    }
  }
}
#endif
