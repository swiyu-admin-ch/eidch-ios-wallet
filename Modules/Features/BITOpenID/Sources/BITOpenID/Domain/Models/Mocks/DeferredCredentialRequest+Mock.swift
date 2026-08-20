#if DEBUG
import Foundation
@testable import BITCore

// MARK: DeferredCredentialContext.Mock

extension DeferredCredentialContext: Mockable {
  struct Mock {
    static let sample = DeferredCredentialContext(
      transactionId: "83d3824-b550-4b8b-aa75-06328385faed",
      accessToken: .Mock.sample,
      endpoint: "https://mock_endpoint",
      format: .vcSdJwt,
      interval: 100)
  }
}
#endif
