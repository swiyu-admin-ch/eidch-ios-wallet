#if DEBUG
import Foundation
@testable import BITCore

// MARK: DeferredCredentialContext.Mock

extension DeferredCredentialContext: Mockable {
  struct Mock {
    static let sample = DeferredCredentialContext(
      transactionId: "83d3824-b550-4b8b-aa75-06328385faed",
      accessToken: "015bc32f-aa17-4399-b4f9-a9bdcc4058e4",
      endpoint: "https://mock_endpoint",
      format: "sd-jwt",
      interval: 100,
      refreshToken: "654bc32f-1111-4399-b4f9-a9XXX4058e4")
  }
}
#endif
