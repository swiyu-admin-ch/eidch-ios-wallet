// swiftlint:disable force_unwrapping
#if DEBUG
import Foundation
@testable import BITAnyCredentialFormat
@testable import BITCore
@testable import BITOpenID

extension DeferredCredential: Mockable {

  public struct Mock {

    // MARK: Public

    public static let sample = DeferredCredential(
      transactionId: transactionId,
      endpoint: endpoint,
      format: format,
      issuerUrl: issuerUrl,
      selectedConfigurationId: selectedConfigurationId,
      keyBindings: [KeyBinding(id: UUID(), algorithm: "ES256", bindingType: .software)],
      rawCredentialData: RawCredentialData(rawOIDMetadata: CredentialIssuerMetadataJWT.Mock.sampleData),
      authentication: CredentialAuthentication(
        accessToken: accessToken,
        refreshToken: refreshToken,
        dpopBinding: KeyBinding(id: UUID(), algorithm: "ES256", bindingType: .software)))

    public static let sampleWithoutKeyBindings = DeferredCredential(
      transactionId: transactionId,
      endpoint: endpoint,
      format: format,
      issuerUrl: issuerUrl,
      selectedConfigurationId: selectedConfigurationId,
      rawCredentialData: RawCredentialData(rawOIDMetadata: CredentialIssuerMetadataJWT.Mock.sampleData),
      authentication: CredentialAuthentication(
        accessToken: accessToken,
        refreshToken: refreshToken,
        dpopBinding: KeyBinding(id: UUID(), algorithm: "ES256", bindingType: .software)))

    public static func sample(
      dpopBinding: KeyBinding,
      authenticationOverrides: (accessToken: String, refreshToken: String?)? = nil)
      -> DeferredCredential
    {
      DeferredCredential(
        transactionId: transactionId,
        endpoint: endpoint,
        format: format,
        issuerUrl: issuerUrl,
        selectedConfigurationId: selectedConfigurationId,
        rawCredentialData: RawCredentialData(rawOIDMetadata: CredentialIssuerMetadataJWT.Mock.sampleData),
        authentication: CredentialAuthentication(
          accessToken: authenticationOverrides?.accessToken ?? accessToken,
          refreshToken: authenticationOverrides?.refreshToken ?? refreshToken,
          dpopBinding: dpopBinding))
    }

    // MARK: Internal

    static let sampleWithoutMetadata = DeferredCredential(
      transactionId: transactionId,
      endpoint: endpoint,
      format: format,
      issuerUrl: issuerUrl,
      selectedConfigurationId: selectedConfigurationId,
      authentication: CredentialAuthentication(accessToken: accessToken, refreshToken: refreshToken))

    static let sampleIncorrectInterval = DeferredCredential(
      transactionId: transactionId,
      endpoint: endpoint,
      format: format,
      issuerUrl: issuerUrl,
      selectedConfigurationId: selectedConfigurationId,
      polledAt: Date().addingTimeInterval(300),
      authentication: CredentialAuthentication(accessToken: accessToken, refreshToken: refreshToken))

    static let sampleWithoutSelectedConfigurationId = DeferredCredential(
      transactionId: transactionId,
      endpoint: endpoint,
      format: format,
      issuerUrl: issuerUrl,
      rawCredentialData: RawCredentialData(rawOIDMetadata: CredentialIssuerMetadataJWT.Mock.sampleData),
      authentication: CredentialAuthentication(accessToken: accessToken, refreshToken: refreshToken))

    static let sampleWithoutValidEndpoint = DeferredCredential(
      transactionId: transactionId,
      endpoint: "",
      format: format,
      issuerUrl: issuerUrl,
      rawCredentialData: RawCredentialData(rawOIDMetadata: CredentialIssuerMetadataJWT.Mock.sampleData),
      authentication: CredentialAuthentication(accessToken: accessToken, refreshToken: refreshToken))

    static let sampleInvalid = DeferredCredential(
      transactionId: transactionId,
      progressionState: .invalid,
      endpoint: endpoint,
      format: format,
      issuerUrl: issuerUrl,
      selectedConfigurationId: selectedConfigurationId,
      authentication: CredentialAuthentication(accessToken: accessToken, refreshToken: refreshToken))

    static let sampleWithoutRefreshToken = DeferredCredential(
      transactionId: transactionId,
      endpoint: endpoint,
      format: format,
      issuerUrl: issuerUrl,
      selectedConfigurationId: selectedConfigurationId,
      rawCredentialData: RawCredentialData(rawOIDMetadata: CredentialIssuerMetadataJWT.Mock.sampleData),
      authentication: CredentialAuthentication(accessToken: "accessToken"))

    static let transactionId = "83d3824-b550-4b8b-aa75-06328385faed"
    static let accessToken = "015bc32f-aa17-4399-b4f9-a9bdcc4058e4"
    static let endpoint = "https://mock_endpoint"
    static let issuerUrl = URL(string: "https://issuer")!
    static let format = CredentialFormat.vcSdJwt
    static let selectedConfigurationId = "sample-credential"
    static let refreshToken = "502b8c3c-5343-4e13-8a72-963fc53d2ea2"
  }
}
#endif
