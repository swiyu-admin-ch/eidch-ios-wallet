#if DEBUG
import Foundation
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
      rawCredentialData: RawCredentialData(rawOIDMetadata: CredentialIssuerMetadata.Mock.sampleData),
      authentication: CredentialAuthentication(accessToken: accessToken, refreshToken: refreshToken))

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
      rawCredentialData: RawCredentialData(rawOIDMetadata: CredentialIssuerMetadata.Mock.sampleData),
      authentication: CredentialAuthentication(accessToken: accessToken, refreshToken: refreshToken))

    static let sampleWithoutValidEndpoint = DeferredCredential(
      transactionId: transactionId,
      endpoint: "",
      format: format,
      issuerUrl: issuerUrl,
      rawCredentialData: RawCredentialData(rawOIDMetadata: CredentialIssuerMetadata.Mock.sampleData),
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
      rawCredentialData: RawCredentialData(rawOIDMetadata: CredentialIssuerMetadata.Mock.sampleData),
      authentication: CredentialAuthentication(accessToken: "accessToken"))

    static let sampleWithoutIssuerUrl = DeferredCredential(
      transactionId: transactionId,
      endpoint: endpoint,
      format: format,
      issuerUrl: "",
      selectedConfigurationId: selectedConfigurationId,
      rawCredentialData: RawCredentialData(rawOIDMetadata: CredentialIssuerMetadata.Mock.sampleData),
      authentication: CredentialAuthentication(accessToken: accessToken, refreshToken: refreshToken))

    static let transactionId = "83d3824-b550-4b8b-aa75-06328385faed"
    static let accessToken = "015bc32f-aa17-4399-b4f9-a9bdcc4058e4"
    static let endpoint = "https://mock_endpoint"
    static let issuerUrl = "https://issuer"
    static let format = "sd-jwt"
    static let selectedConfigurationId = "elfa-sdjwt"
    static let refreshToken = "refreshToken"
  }
}
#endif
