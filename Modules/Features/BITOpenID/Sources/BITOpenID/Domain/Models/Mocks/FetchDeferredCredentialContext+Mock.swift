#if DEBUG
import BITCrypto
import Foundation
@testable import BITCore
@testable import BITVault

// swiftlint:disable force_unwrapping

extension FetchDeferredCredentialContext {
  enum Mock {
    // MARK: Internal

    static let sample = FetchDeferredCredentialContext(
      format: "vc+sd-jwt",
      accessToken: "accessToken",
      deferredCredentialEndpoint: URL(string: "https://example.com")!,
      privateKey: nil,
      refreshToken: "refreshToken")

    static let sampleWithEncryption = FetchDeferredCredentialContext(
      format: "vc+sd-jwt",
      accessToken: "accessToken",
      deferredCredentialEndpoint: URL(string: "https://example.com")!,
      privateKey: VaultKeyPair.Mock.ES256.privateKey,
      refreshToken: "refreshToken")
  }
}
#endif
