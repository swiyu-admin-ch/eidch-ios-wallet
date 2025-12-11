#if DEBUG
import Foundation
@testable import BITTestingCore

// MARK: DeferredCredentialRequest.Mock

extension DeferredCredentialRequest: Mockable {
  struct Mock {
    static let sample = DeferredCredentialRequest(
      transactionId: "83d3824-b550-4b8b-aa75-06328385faed",
      accessToken: "015bc32f-aa17-4399-b4f9-a9bdcc4058e4",
      endpoint: "https://mock_endpoint",
      format: "sd-jwt",
      interval: 100)
  }
}
#endif
