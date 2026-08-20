#if DEBUG
import BITCrypto
import Foundation
@testable import BITCore
@testable import BITVault

// swiftlint:disable force_unwrapping

extension FetchDeferredCredentialContext {
  enum Mock {
    static let sample = FetchDeferredCredentialContext(
      format: .vcSdJwt,
      authorization: IssuanceAuthorization(
        accessToken: AccessToken(
          accessToken: "accessToken",
          tokenType: .bearer,
          refreshToken: "refreshToken")),
      deferredCredentialEndpoint: URL(string: "https://example.com")!,
      credentialEncryptionContext: .Mock.sample)
  }
}
#endif
