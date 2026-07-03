import BITAnyCredentialFormat
import BITClaimsPathPointer
import BITVault
import Factory

// MARK: - AnyVpTokenGeneratorError

enum AnyVpTokenGeneratorError: Error {
  case invalidFormat
}

// MARK: - AnyVpTokenGenerator

struct AnyVpTokenGenerator: AnyVpTokenGeneratorProtocol {
  init(anyVpTokenGeneratorDispatcher: [CredentialFormat: AnyVpTokenGeneratorProtocol] = Container.shared.anyVpTokenGeneratorDispatcher()) {
    dispatcher = anyVpTokenGeneratorDispatcher
  }

  func generate(requestObject: RequestObject, credential: any AnyCredential, keyPair: VaultKeyPair?, paths: [ClaimsPathPointer]) throws -> VpToken {
    guard let credentialFormat = CredentialFormat(rawValue: credential.format), let dispatcherFormat = dispatcher[credentialFormat] else {
      throw CredentialFormatError.formatNotSupported
    }

    return try dispatcherFormat.generate(requestObject: requestObject, credential: credential, keyPair: keyPair, paths: paths)
  }

  private let dispatcher: [CredentialFormat: AnyVpTokenGeneratorProtocol]
}
