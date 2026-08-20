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
  func callAsFunction(credentials: [AnyCredential], keyPairs: [VaultKeyPair]) throws -> [CredentialWithKeyBinding]
  func callAsFunction(credentials: [AnyCredential], keyBindings: [KeyBinding]) throws -> [CredentialWithKeyBinding]
}

// MARK: - CredentialWithKeyBinding

struct CredentialWithKeyBinding {
  let credential: AnyCredential
  let keyBinding: KeyBinding?
}

// MARK: - MapCredentialsToKeyBindingsUseCase

struct MapCredentialsToKeyBindingsUseCase: MapCredentialsToKeyBindingsUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(credentials: [AnyCredential], keyPairs: [VaultKeyPair]) throws -> [CredentialWithKeyBinding] {
    guard !credentials.isEmpty else {
      return []
    }

    let keyBindingJwkPairs: [KeyBinding: JWK] = try Dictionary(
      uniqueKeysWithValues: keyPairs.compactMap { keyPair -> (KeyBinding, JWK)? in
        guard
          let keyBinding = try keyBindingGenerator.generate(from: keyPair)
        else { return nil }

        return try (keyBinding, jwkGenerator(from: keyPair))
      })

    return try credentials.map { credential in
      guard let vcSdJwt = credential as? VcSdJWS else {
        throw MapCredentialsToKeyBindingsUseCaseError.invalidCredentialFormat
      }

      guard let cnfJwk = vcSdJwt.payload.keyBinding?.jwk else {
        return CredentialWithKeyBinding(credential: credential, keyBinding: nil)
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

  func callAsFunction(credentials: [AnyCredential], keyBindings: [KeyBinding]) throws -> [CredentialWithKeyBinding] {
    let keyPairs = try keyBindings.map { keyBinding in
      guard let algorithm = VaultAlgorithm(rawValue: keyBinding.algorithm) else {
        throw MapCredentialsToKeyBindingsUseCaseError.invalidKeyBindingAlgorithm
      }

      let options: VaultOptions = keyBinding.bindingType == .hardware ? .secureEnclave : .none
      return try keyManager.getKeyPair(withIdentifier: keyBinding.id.uuidString, algorithm: algorithm, options: options)
    }

    return try callAsFunction(credentials: credentials, keyPairs: keyPairs)
  }

  // MARK: Private

  @Injected(\.keyManager) private var keyManager
  @Injected(\.keyBindingGenerator) private var keyBindingGenerator
  @Injected(\.jwkGenerator) private var jwkGenerator
}

// MARK: - MapCredentialsToKeyBindingsUseCaseError

enum MapCredentialsToKeyBindingsUseCaseError: Error {
  case invalidCredentialFormat
  case noMatchingKeyBinding
  case invalidKeyBindingAlgorithm
}
