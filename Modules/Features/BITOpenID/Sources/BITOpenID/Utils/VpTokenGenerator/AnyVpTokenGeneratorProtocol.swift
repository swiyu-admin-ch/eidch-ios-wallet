import BITAnyCredentialFormat
import BITClaimsPathPointer
import BITVault
import Foundation
import Spyable

public typealias VpToken = String

// MARK: - AnyVpTokenGeneratorProtocol

@Spyable
public protocol AnyVpTokenGeneratorProtocol {
  func generate(requestObject: RequestObject, credential: any AnyCredential, keyPair: VaultKeyPair?, paths: [ClaimsPathPointer], withOrigin: String?) throws -> VpToken
}
