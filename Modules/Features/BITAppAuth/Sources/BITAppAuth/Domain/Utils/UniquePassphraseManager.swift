import BITCrypto
import BITLocalAuthentication
import Factory
import Foundation
import Spyable

// MARK: - UniquePassphraseManagerProtocol

@Spyable
public protocol UniquePassphraseManagerProtocol {
  func generate() throws -> Data
  func save(uniquePassphrase: Data, for authMethod: AuthMethod, context: LAContextProtocol) throws
  func exists(for authMethod: AuthMethod) -> Bool
  func deleteBiometricUniquePassphrase() throws
  @discardableResult
  func getUniquePassphrase(authMethod: AuthMethod, context: LAContextProtocol) throws -> Data
}

// MARK: - UniquePassphraseManager

struct UniquePassphraseManager: UniquePassphraseManagerProtocol {

  // MARK: Internal

  func generate() throws -> Data {
    try Data.random(length: passphraseLength)
  }

  func save(uniquePassphrase: Data, context: LAContextProtocol) throws {
    try uniquePassphraseRepository.saveUniquePassphrase(uniquePassphrase, forAuthMethod: .appPin, inContext: context)
    if getBiometricStateUseCase() == .enabled {
      try uniquePassphraseRepository.saveUniquePassphrase(uniquePassphrase, forAuthMethod: .biometric, inContext: context)
    }
  }

  func save(uniquePassphrase: Data, for authMethod: AuthMethod, context: LAContextProtocol) throws {
    try uniquePassphraseRepository.saveUniquePassphrase(uniquePassphrase, forAuthMethod: authMethod, inContext: context)
  }

  func exists(for authMethod: AuthMethod) -> Bool {
    uniquePassphraseRepository.hasUniquePassphraseSaved(forAuthMethod: authMethod)
  }

  func getUniquePassphrase(authMethod: AuthMethod, context: LAContextProtocol) throws -> Data {
    try uniquePassphraseRepository.getUniquePassphrase(forAuthMethod: authMethod, inContext: context)
  }

  func deleteBiometricUniquePassphrase() throws {
    try uniquePassphraseRepository.deleteBiometricUniquePassphrase()
  }

  // MARK: Private

  @Injected(\.passphraseLength) private var passphraseLength: Int
  @Injected(\.getBiometricStateUseCase) private var getBiometricStateUseCase: GetBiometricStateUseCaseProtocol
  @Injected(\.uniquePassphraseRepository) private var uniquePassphraseRepository: UniquePassphraseRepositoryProtocol

}
