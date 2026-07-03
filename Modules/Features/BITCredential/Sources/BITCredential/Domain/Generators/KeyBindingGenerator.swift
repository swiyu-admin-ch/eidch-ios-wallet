import BITCredentialShared
import BITVault
import Factory
import Foundation
import Spyable

// MARK: - KeyBindingGeneratorProtocol

@Spyable
protocol KeyBindingGeneratorProtocol {
  func generate(from keyPair: VaultKeyPair?) throws -> KeyBinding?
}

// MARK: - KeyBindingGenerator

struct KeyBindingGenerator: KeyBindingGeneratorProtocol {

  // MARK: Internal

  func generate(from keyPair: VaultKeyPair?) throws -> KeyBinding? {
    try keyPair.flatMap { keyPair in
      let isHardwareKey = keyPair.options?.contains(.secureEnclave) ?? false

      let key: (rawPublicKey: Data?, rawPrivateKey: Data?) = if isHardwareKey {
        (nil, nil)
      } else {
        try keyManager.getExternalRepresentation(of: keyPair.privateKey)
      }

      return KeyBinding(
        id: UUID(uuidString: keyPair.identifier) ?? UUID(),
        algorithm: keyPair.algorithm.rawValue,
        bindingType: isHardwareKey ? .hardware : .software,
        publicKey: key.rawPublicKey,
        privateKey: key.rawPrivateKey)
    }
  }

  // MARK: Private

  @Injected(\.keyManager) private var keyManager: KeyManagerProtocol
}
