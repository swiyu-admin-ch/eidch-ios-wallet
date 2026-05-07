import BITAnyCredentialFormat
import BITCredentialShared
import BITCrypto
import BITSdJWT
import BITVault
import Factory
import Foundation
import Spyable

// MARK: - MapCredentialsToKeyBindingsUseCaseProtocol

@Spyable
protocol MapCredentialsToKeyBindingsUseCaseProtocol {
  func execute(credentials: [AnyCredential], keyPairs: [VaultKeyPair]) throws -> [CredentialWithKeyBinding]
  func execute(credentials: [AnyCredential], keyBindings: [KeyBinding]) throws -> [CredentialWithKeyBinding]
}

// MARK: - CredentialWithKeyBinding

struct CredentialWithKeyBinding {
  let credential: AnyCredential
  let keyBinding: KeyBinding?
}

// MARK: - MapCredentialsToKeyBindingsUseCase

struct MapCredentialsToKeyBindingsUseCase: MapCredentialsToKeyBindingsUseCaseProtocol {

  // MARK: Internal

  func execute(credentials: [AnyCredential], keyPairs: [VaultKeyPair]) throws -> [CredentialWithKeyBinding] {
    guard !credentials.isEmpty else {
      return []
    }

    let keyBindingJwkPairs: [KeyBinding: JWK] = try Dictionary(
      uniqueKeysWithValues: keyPairs.compactMap { keyPair in
        guard
          let keyBinding = try createKeyBinding(from: keyPair),
          let publicKey = keyPair.publicKey
        else { return nil }

        return try (keyBinding, JWK(from: publicKey))
      })

    return try credentials.map { credential in
      guard let vcSdJwt = credential as? VcSdJWS else {
        throw MapCredentialsToKeyBindingsUseCaseError.invalidCredentialFormat
      }

      guard let cnfJwk = vcSdJwt.payload.keyBinding?.jwk else {
        throw MapCredentialsToKeyBindingsUseCaseError.noMatchingKeyBinding
      }

      guard
        let keyBinding = keyBindingJwkPairs.first(where: { _, jwk in
          jwk == cnfJwk
        })?.key
      else {
        throw MapCredentialsToKeyBindingsUseCaseError.noMatchingKeyBinding
      }

      return CredentialWithKeyBinding(credential: credential, keyBinding: keyBinding)
    }
  }

  func execute(credentials: [AnyCredential], keyBindings: [KeyBinding]) throws -> [CredentialWithKeyBinding] {
    let keyPairs = try keyBindings.map { keyBinding in
      guard let algorithm = VaultAlgorithm(rawValue: keyBinding.algorithm) else {
        throw MapCredentialsToKeyBindingsUseCaseError.invalidKeyBindingAlgorithm
      }
      return try keyManager.getKeyPair(withIdentifier: keyBinding.id.uuidString, algorithm: algorithm)
    }

    return try execute(credentials: credentials, keyPairs: keyPairs)
  }

  // MARK: Private

  @Injected(\.keyManager) private var keyManager: KeyManagerProtocol

  private func createKeyBinding(from keyPair: VaultKeyPair?) throws -> KeyBinding? {
    try keyPair.flatMap { keyPair in
      let isHardwareKey = keyPair.options?.contains(.secureEnclave) ?? false
      let (publicKey, privateKey): (Data?, Data?) = isHardwareKey
        ? (nil, nil)
        : try keyManager.getExternalRepresentation(of: keyPair.privateKey)

      return KeyBinding(
        id: UUID(uuidString: keyPair.identifier) ?? UUID(),
        algorithm: keyPair.algorithm.rawValue,
        bindingType: isHardwareKey ? .hardware : .software,
        publicKey: publicKey,
        privateKey: privateKey)
    }
  }
}

// MARK: - MapCredentialsToKeyBindingsUseCaseError

enum MapCredentialsToKeyBindingsUseCaseError: Error {
  case invalidCredentialFormat
  case noMatchingKeyBinding
  case invalidKeyBindingAlgorithm
}
