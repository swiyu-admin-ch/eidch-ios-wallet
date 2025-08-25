import BITAnyCredentialFormat
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

  func generate(requestObject: RequestObject, credential: any AnyCredential, keyPair: VaultKeyPair?, fields: [String]) throws -> VpToken {
    guard let credentialFormat = CredentialFormat(rawValue: credential.format), let dispatcherFormat = dispatcher[credentialFormat] else {
      throw CredentialFormatError.formatNotSupported
    }

    return try dispatcherFormat.generate(requestObject: requestObject, credential: credential, keyPair: keyPair, fields: fields)
  }

  private let dispatcher: [CredentialFormat: AnyVpTokenGeneratorProtocol]
}
