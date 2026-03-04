#if DEBUG
import Foundation
@testable import BITOpenID
@testable import BITTestingCore

extension DeferredCredential: Mockable {

  public struct Mock {

    // MARK: Public

    public static let sample = DeferredCredential(
      transactionId: transactionId,
      accessToken: accessToken,
      endpoint: endpoint,
      format: format,
      issuerUrl: issuerUrl,
      selectedConfigurationId: selectedConfigurationId,
      rawCredentialData: RawCredentialData(rawOIDMetadata: CredentialMetadata.Mock.sampleData))

    // MARK: Internal

    static let sampleWithoutMetadata = DeferredCredential(
      transactionId: transactionId,
      accessToken: accessToken,
      endpoint: endpoint,
      format: format,
      issuerUrl: issuerUrl,
      selectedConfigurationId: selectedConfigurationId)

    static let sampleIncorrectInterval = DeferredCredential(
      transactionId: transactionId,
      accessToken: accessToken,
      endpoint: endpoint,
      format: format,
      issuerUrl: issuerUrl,
      selectedConfigurationId: selectedConfigurationId,
      polledAt: Date().addingTimeInterval(300))

    static let sampleWithoutSelectedConfigurationId = DeferredCredential(
      transactionId: transactionId,
      accessToken: accessToken,
      endpoint: endpoint,
      format: format,
      issuerUrl: issuerUrl,
      rawCredentialData: RawCredentialData(rawOIDMetadata: CredentialMetadata.Mock.sampleData))

    static let sampleWithoutValidEndpoint = DeferredCredential(
      transactionId: transactionId,
      accessToken: accessToken,
      endpoint: "",
      format: format,
      issuerUrl: issuerUrl,
      rawCredentialData: RawCredentialData(rawOIDMetadata: CredentialMetadata.Mock.sampleData))

    static let sampleInvalid = DeferredCredential(
      transactionId: transactionId,
      progressionState: .invalid,
      accessToken: accessToken,
      endpoint: endpoint,
      format: format,
      issuerUrl: issuerUrl,
      selectedConfigurationId: selectedConfigurationId)

    static let transactionId = "83d3824-b550-4b8b-aa75-06328385faed"
    static let accessToken = "015bc32f-aa17-4399-b4f9-a9bdcc4058e4"
    static let endpoint = "https://mock_endpoint"
    static let issuerUrl = "https://issuer"
    static let format = "sd-jwt"
    static let selectedConfigurationId = "elfa-sdjwt"
  }
}
#endif
