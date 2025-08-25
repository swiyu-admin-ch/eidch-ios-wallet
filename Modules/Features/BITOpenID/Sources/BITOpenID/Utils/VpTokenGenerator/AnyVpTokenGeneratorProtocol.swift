import BITAnyCredentialFormat
import BITVault
import Foundation
import Spyable

public typealias VpToken = String

// MARK: - AnyVpTokenGeneratorProtocol

@Spyable
public protocol AnyVpTokenGeneratorProtocol {
  func generate(requestObject: RequestObject, credential: any AnyCredential, keyPair: VaultKeyPair?, fields: [String]) throws -> VpToken
}
