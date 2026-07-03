public enum TrustStatementType {
  public static let identity = "swiyu-identity-trust-statement+jwt"
  public static let verificationQueryPublic = "swiyu-verification-query-public-statement+jwt"
  public static let protectedIssuanceTrustList = "swiyu-protected-issuance-trust-list-statement+jwt"
  public static let protectedIssuanceAuthorization = "swiyu-protected-issuance-authorization-trust-statement+jwt"
  public static let nonComplianceTrustList = "swiyu-non-compliance-trust-list-statement+jwt"
  public static let protectedVerificationAuthorization = "swiyu-protected-verification-authorization-trust-statement+jwt"
}
