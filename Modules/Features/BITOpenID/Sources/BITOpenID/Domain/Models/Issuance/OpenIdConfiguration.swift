import Foundation

// MARK: - OpenIdConfiguration

/// A srtructure representing OpenID Provider Metadata.
/// This structure is based on the OpenID Connect 1.0
/// https://openid.net/specs/openid-connect-discovery-1_0.html
public struct OpenIdConfiguration: Codable, Equatable {

  // MARK: Internal

  enum CodingKeys: String, CodingKey {
    case issuerEndpoint = "issuer"
    case tokenEndpoint = "token_endpoint"
    case jwksURI = "jwks_uri"

    case authorizationEndpoint = "authorization_endpoint"
    case userinfoEndpoint = "userinfo_endpoint"
    case registrationEndpoint = "registration_endpoint"
    case scopesSupported = "scopes_supported"
    case responseTypesSupported = "response_types_supported"
    case responseModesSupported = "response_modes_supported"
    case grantTypesSupported = "grant_types_supported"
    case acrValuesSupported = "acr_values_supported"
    case subjectTypesSupported = "subject_types_supported"
    case idTokenSigningAlgValuesSupported = "id_token_signing_alg_values_supported"
    case idTokenEncryptionAlgValuesSupported = "id_token_encryption_alg_values_supported"
    case idTokenEncryptionEncValuesSupported = "id_token_encryption_enc_values_supported"
    case userinfoSigningAlgValuesSupported = "userinfo_signing_alg_values_supported"
    case userinfoEncryptionAlgValuesSupported = "userinfo_encryption_alg_values_supported"
    case userinfoEncryptionEncValuesSupported = "userinfo_encryption_enc_values_supported"
    case requestObjectSigningAlgValuesSupported = "request_object_signing_alg_values_supported"
    case requestObjectEncryptionAlgValuesSupported = "request_object_encryption_alg_values_supported"
    case requestObjectEncryptionEncValuesSupported = "request_object_encryption_enc_values_supported"
    case tokenEndpointAuthMethodsSupported = "token_endpoint_auth_methods_supported"
    case tokenEndpointAuthSigningAlgValuesSupported = "token_endpoint_auth_signing_alg_values_supported"
    case displayValuesSupported = "display_values_supported"
    case claimTypesSupported = "claim_types_supported"
    case claimsSupported = "claims_supported"
    case serviceDocumentation = "service_documentation"
    case claimsLocalesSupported = "claims_locales_supported"
    case uiLocalesSupported = "ui_locales_supported"
    case claimsParameterSupported = "claims_parameter_supported"
    case requestParameterSupported = "request_parameter_supported"
    case requestURIParameterSupported = "request_uri_parameter_supported"
    case requireRequestURIRegistration = "require_request_uri_registration"
    case opPolicyURI = "op_policy_uri"
    case opTosURI = "op_tos_uri"
    case checkSessionIframe = "check_session_iframe"
    case endSessionEndpoint = "end_session_endpoint"
    case revocationEndpoint = "revocation_endpoint"
    case introspectionEndpoint = "introspection_endpoint"
    case codeChallengeMethodsSupported = "code_challenge_methods_supported"
    case tlsClientCertificateBoundAccessTokens = "tls_client_certificate_bound_access_tokens"
    case frontchannelLogoutSupported = "frontchannel_logout_supported"
    case frontchannelLogoutSessionSupported = "frontchannel_logout_session_supported"
    case backchannelLogoutSupported = "backchannel_logout_supported"
    case backchannelLogoutSessionSupported = "backchannel_logout_session_supported"
  }

  let issuerEndpoint: String

  // MARK: Public

  public let tokenEndpoint: URL

  let jwksURI: URL?

  let authorizationEndpoint: String?
  let responseTypesSupported: [String]?
  let subjectTypesSupported: [String]?
  let idTokenSigningAlgValuesSupported: [String]?
  let userinfoEndpoint: String?
  let registrationEndpoint: String?
  let scopesSupported: [String]?
  let responseModesSupported: [String]?
  let grantTypesSupported: [String]?
  let acrValuesSupported: [String]?
  let idTokenEncryptionAlgValuesSupported: [String]?
  let idTokenEncryptionEncValuesSupported: [String]?
  let userinfoSigningAlgValuesSupported: [String]?
  let userinfoEncryptionAlgValuesSupported: [String]?
  let userinfoEncryptionEncValuesSupported: [String]?
  let requestObjectSigningAlgValuesSupported: [String]?
  let requestObjectEncryptionAlgValuesSupported: [String]?
  let requestObjectEncryptionEncValuesSupported: [String]?
  let tokenEndpointAuthMethodsSupported: [String]?
  let tokenEndpointAuthSigningAlgValuesSupported: [String]?
  let displayValuesSupported: [String]?
  let claimTypesSupported: [String]?
  let claimsSupported: [String]?
  let serviceDocumentation: String?
  let claimsLocalesSupported: [String]?
  let uiLocalesSupported: [String]?
  let claimsParameterSupported: Bool?
  let requestParameterSupported: Bool?
  let requestURIParameterSupported: Bool?
  let requireRequestURIRegistration: Bool?
  let opPolicyURI: String?
  let opTosURI: String?
  let checkSessionIframe: String?
  let endSessionEndpoint: String?
  let revocationEndpoint: String?
  let introspectionEndpoint: String?
  let codeChallengeMethodsSupported: [String]?
  let tlsClientCertificateBoundAccessTokens: Bool?
  let frontchannelLogoutSupported: Bool?
  let frontchannelLogoutSessionSupported: Bool?
  let backchannelLogoutSupported: Bool?
  let backchannelLogoutSessionSupported: Bool?

  // MARK: Private

  private enum DecodingError: Error {
    case invalidURL(String)
  }

}
