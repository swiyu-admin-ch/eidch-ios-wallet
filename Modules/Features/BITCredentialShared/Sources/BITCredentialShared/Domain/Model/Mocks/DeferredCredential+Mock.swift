#if DEBUG
import Foundation
@testable import BITOpenID
@testable import BITTestingCore

extension DeferredCredential: Mockable {

  struct Mock {
    static let sample = DeferredCredential(
      transactionId: transactionId,
      accessToken: accessToken,
      endpoint: endpoint,
      format: format,
      selectedConfigurationId: selectedConfigurationId,
      rawCredentialData: RawCredentialData(rawOIDMetadata: CredentialMetadata.Mock.sampleData))

    static let sampleWithoutMetadata = DeferredCredential(
      transactionId: transactionId,
      accessToken: accessToken,
      endpoint: endpoint,
      format: format,
      selectedConfigurationId: selectedConfigurationId)

    static let sampleIncorrectInterval = DeferredCredential(
      transactionId: transactionId,
      accessToken: accessToken,
      endpoint: endpoint,
      format: format,
      selectedConfigurationId: selectedConfigurationId,
      polledAt: Date().addingTimeInterval(300))

    static let sampleWithoutSelectedConfigurationId = DeferredCredential(
      transactionId: transactionId,
      accessToken: accessToken,
      endpoint: endpoint,
      format: format,
      rawCredentialData: RawCredentialData(rawOIDMetadata: CredentialMetadata.Mock.sampleData))

    static let sampleWithoutValidEndpoint = DeferredCredential(
      transactionId: transactionId,
      accessToken: accessToken,
      endpoint: "",
      format: format,
      rawCredentialData: RawCredentialData(rawOIDMetadata: CredentialMetadata.Mock.sampleData))

    static let transactionId = "83d3824-b550-4b8b-aa75-06328385faed"
    static let accessToken = "015bc32f-aa17-4399-b4f9-a9bdcc4058e4"
    static let endpoint = "https://mock_endpoint"
    static let format = "sd-jwt"
    static let selectedConfigurationId = "elfa-sdjwt"
  }
}
#endif
