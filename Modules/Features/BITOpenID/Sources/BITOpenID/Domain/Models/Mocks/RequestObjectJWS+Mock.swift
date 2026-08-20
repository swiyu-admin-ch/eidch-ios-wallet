#if DEBUG
import Foundation
@testable import BITCore
@testable import BITJWT

extension RequestObjectJWS: Mockable {
  public struct Mock {

    // MARK: Public

    public static let sampleData = getData(fromFile: "request-object-jwt", bundle: Bundle.module) ?? Data()
    public static let sampleWithoutVerifiedQueryData = getData(fromFile: "request-object-jwt-without-verified-query", bundle: Bundle.module) ?? Data()
    public static let sampleWithProtectedClaimsData = getData(fromFile: "request-object-jwt-with-protected-claims", bundle: Bundle.module) ?? Data()
    public static let duplicateIdTS = getData(fromFile: "request-object-jwt-duplicate-idts", bundle: Bundle.module) ?? Data()
    public static let missingDcqlQueryAndScopeData = getData(fromFile: "request-object-jwt-missing-dcql-query-and-scope", bundle: Bundle.module) ?? Data()
    public static let dcqlQueryAndScopeData = getData(fromFile: "request-object-jwt-dcql-query-and-scope", bundle: Bundle.module) ?? Data()
    public static let missingVqPS = getData(fromFile: "request-object-jwt-missing-vqps", bundle: Bundle.module) ?? Data()
    public static let queryScopeMismatch = getData(fromFile: "request-object-jwt-query-scope-mismatch", bundle: Bundle.module) ?? Data()
    public static let duplicateVqPS = getData(fromFile: "request-object-jwt-duplicate-vqps", bundle: Bundle.module) ?? Data()
    public static let duplicatePvaTS = getData(fromFile: "request-object-jwt-duplicate-pvats", bundle: Bundle.module) ?? Data()
    public static let withoutClientMetadataData = getData(fromFile: "request-object-jwt-no-client-metadata", bundle: Bundle.module) ?? Data()
    public static let unsupportedClientMetadata = getData(fromFile: "request-object-jwt-unsupported-client-metadata", bundle: Bundle.module) ?? Data()
    public static let withConstraintsData = getData(fromFile: "request-object-jwt-with-constraints", bundle: Bundle.module) ?? Data()
    public static let clientIdNotADidData = getData(fromFile: "request-object-jwt-client-id-not-a-did", bundle: Bundle.module) ?? Data()
    public static let unsupportedClientIdData = getData(fromFile: "request-object-jwt-with-unsupported-client-id", bundle: Bundle.module) ?? Data()

    public static let sampleJWT: RequestObjectJWT = decode(
      fromFile: "request-object-jwt", dateFormatter: .secondsSince1970, bundle: Bundle.module)

    public static let sample: RequestObjectJWS = createObject(header: jwsHeader)
    public static let sampleProximity: RequestObjectJWS = createObject(header: jwsHeader, payload: proximityRequest)
    public static let sampleWithoutVerifiedQuery: RequestObjectJWS = createObject(header: jwsHeader, payload: sampleWithoutVerifiedQueryPayload)
    public static let identityTrustedWithoutVerifiedQuery: RequestObjectJWS = createObject(header: jwsHeader, payload: identityTrustedWithoutVerifiedQueryPayload)
    public static let sampleWithProtectedClaims: RequestObjectJWS = createObject(header: jwsHeader, payload: sampleWithProtectedClaimsPayload)
    public static let sampleWithProtectedClaimsWithoutIdentityTrust: RequestObjectJWS = createObject(header: jwsHeader, payload: sampleWithProtectedClaimsWithoutIdentityTrustPayload)
    public static let clientIdDIDPrefix: RequestObjectJWS = createObject(header: jwsHeader, payload: clientIdDidPrefixPayload)

    public static let verifierAttestationPrefix: RequestObjectJWS = createObject(header: verifierAttestationJwsHeader, payload: proximityRequest, rawJWS: rawJWSWithAttestationHeader)
    public static let verifierAttestationMissingHeader: RequestObjectJWS = createObject(header: verifierAttestationJwsHeader, payload: proximityRequest, rawJWS: rawJWSWithoutAttestationHeader)
    public static let kidMismatch: RequestObjectJWS = createObject(header: jwsHeaderDidMismatch, payload: clientIdDidPrefixPayload)

    public static let withoutIdentityTrust: RequestObjectJWS = createObject(header: jwsHeader, payload: withoutIdentityTrustPayload)
    public static let unsupportedResponseType: RequestObjectJWS = createObject(header: jwsHeader, payload: unsupportedResponseTypePayload)
    public static let transactionData: RequestObjectJWS = createObject(header: jwsHeader, payload: transactionDataPayload)
    public static let missingState: RequestObjectJWS = createObject(header: jwsHeader, payload: missingStatePayload)
    public static let noVct: RequestObjectJWS = createObject(header: jwsHeader, payload: noVctPayload)
    public static let clientIdMismatch: RequestObjectJWS = createObject(header: jwsHeader, payload: clientIdMismatchPayload)
    public static let unsupportedAlgorithm: RequestObjectJWS = createObject(header: JWSHeader(algorithm: JWTAlgorithm.ES384))
    public static let audienceIssuerMismatch: RequestObjectJWS = createObject(header: jwsHeader, payload: audienceIssuerMismatchPayload)
    public static let noAudience: RequestObjectJWS = createObject(header: jwsHeader, payload: noAudiencePayload)

    // MARK: Private

    private static let clientIdMismatchPayload: RequestObjectJWT = Mocker.decode(fromFile: "request-object-jwt-client-id-mismatch", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    private static let proximityRequest: RequestObjectJWT = Mocker.decode(fromFile: "request-object-dc-api-proximity", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    private static let sampleWithoutVerifiedQueryPayload: RequestObjectJWT = Mocker.decode(fromFile: "request-object-jwt-without-verified-query", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    private static let identityTrustedWithoutVerifiedQueryPayload: RequestObjectJWT = Mocker.decode(fromFile: "request-object-jwt-with-identity-trust-without-verified-query", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    private static let sampleWithProtectedClaimsPayload: RequestObjectJWT = Mocker.decode(fromFile: "request-object-jwt-with-protected-claims", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    private static let sampleWithProtectedClaimsWithoutIdentityTrustPayload: RequestObjectJWT = Mocker.decode(fromFile: "request-object-jwt-with-protected-claims-without-identity-trust", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    private static let noVctPayload: RequestObjectJWT = Mocker.decode(fromFile: "request-object-jwt-no-vct", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    private static let withoutIdentityTrustPayload: RequestObjectJWT = Mocker.decode(fromFile: "request-object-jwt-without-identity-trust", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    private static let clientIdDidPrefixPayload: RequestObjectJWT = decode(fromFile: "request-object-jwt-did-prefix", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    private static let unsupportedResponseTypePayload: RequestObjectJWT = decode(fromFile: "request-object-jwt-unsupported-response-type", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    private static let transactionDataPayload: RequestObjectJWT = decode(fromFile: "request-object-jwt-with-transaction-data", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    private static let missingStatePayload: RequestObjectJWT = decode(fromFile: "request-object-jwt-missing-state", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    private static let audienceIssuerMismatchPayload: RequestObjectJWT = decode(fromFile: "request-object-jwt-audience-mismatch", dateFormatter: .secondsSince1970, bundle: Bundle.module)
    private static let noAudiencePayload: RequestObjectJWT = decode(fromFile: "request-object-jwt-no-audience", dateFormatter: .secondsSince1970, bundle: Bundle.module)

    private static let jwsHeader = JWSHeader(
      algorithm: JWTAlgorithm.ES256, type: "oauth-authz-req+jwt",
      keyIdentifier: "did:example:12345#key-1")
    private static let jwsHeaderDidMismatch = JWSHeader(
      algorithm: JWTAlgorithm.ES256, keyIdentifier: "did:example:mismatch#key-1")
    private static let verifierAttestationJwsHeader = JWSHeader(
      algorithm: JWTAlgorithm.ES256,
      type: "oauth-authz-req+jwt",
      keyIdentifier: nil)

    /// Compact JWS whose protected header carries a `jwt` parameter (the verifier attestation JWT).
    private static let rawJWSWithAttestationHeader = compactJWS(
      header: #"{"alg":"ES256","typ":"oauth-authz-req+jwt","jwt":"raw.attestation.jwt"}"#)
    /// Compact JWS whose protected header has no `jwt` parameter.
    private static let rawJWSWithoutAttestationHeader = compactJWS(
      header: #"{"alg":"ES256","typ":"oauth-authz-req+jwt"}"#)

    private static func createObject(
      header: JWSHeader, payload: RequestObjectJWT = sampleJWT, rawJWS: String = "rawJWS")
      -> RequestObjectJWS
    {
      JWS(payload: payload, rawPayload: "{\"iss\":\"issuer\"}", rawJWS: rawJWS, header: header)
    }

    private static func compactJWS(header: String) -> String {
      let encodedHeader = Data(header.utf8).base64EncodedString()
        .replacingOccurrences(of: "=", with: "")
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
      return "\(encodedHeader).payload.signature"
    }
  }
}
#endif
