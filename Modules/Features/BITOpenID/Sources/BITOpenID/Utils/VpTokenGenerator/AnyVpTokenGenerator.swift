import BITAnyCredentialFormat
import BITClaimsPathPointer
import BITVault
import Factory

// MARK: - AnyVpTokenGeneratorError

enum AnyVpTokenGeneratorError: Error {
  case invalidFormat
  case missingDcApiOrigin
}

// MARK: - AnyVpTokenGenerator

struct AnyVpTokenGenerator: AnyVpTokenGeneratorProtocol {
  init(anyVpTokenGeneratorDispatcher: [CredentialFormat: AnyVpTokenGeneratorProtocol] = Container.shared.anyVpTokenGeneratorDispatcher()) {
    dispatcher = anyVpTokenGeneratorDispatcher
  }

  func generate(requestObject: RequestObject, credential: any AnyCredential, keyPair: VaultKeyPair?, paths: [ClaimsPathPointer], withOrigin: String?) throws -> VpToken {
    guard let dispatcherFormat = dispatcher[credential.format] else {
      throw CredentialFormatError.formatNotSupported
    }

    return try dispatcherFormat.generate(requestObject: requestObject, credential: credential, keyPair: keyPair, paths: paths, withOrigin: withOrigin)
  }

  private let dispatcher: [CredentialFormat: AnyVpTokenGeneratorProtocol]
}
