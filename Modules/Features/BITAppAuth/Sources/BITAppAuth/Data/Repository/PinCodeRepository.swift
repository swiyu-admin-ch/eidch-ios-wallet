import BITCrypto
import BITVault
import Factory
import Foundation
import Security

// MARK: - PinCodeRepository

struct PinCodeRepository: PinCodeSecretStoreProtocol {

  // MARK: Internal

  @discardableResult
  func createPinCodeSecretMaterial() throws -> PinCodeSecretMaterial {
    let salt = try Data.random(length: appPinSaltLength)
    try setPinSalt(salt)

    let initialVector = try Data.random(length: pepperKeyInitialVectorLength)
    try setPepperInitialVector(initialVector)

    return try PinCodeSecretMaterial(
      salt: salt,
      pepperKey: appPepperKeyRepository.create().privateKey,
      initialVector: initialVector)
  }

  func getPinCodeSecretMaterial() throws -> PinCodeSecretMaterial {
    try PinCodeSecretMaterial(
      salt: getPinSalt(),
      pepperKey: appPepperKeyRepository.get().privateKey,
      initialVector: getPepperInitialVector())
  }

  // MARK: Private

  private enum Key {
    static let authenticationService = "ch.admin.foitt.federal-wallet.authentication"
    static let saltAppPinIdentifier = "saltAppPinIdentifierKey"
    static let pepperInitialVectorIdentifier = "pepperInitialVectorIdentifierKey"
  }

  private enum Error: Swift.Error {
    case unavailableData
  }

  private enum SecretConfiguration {
    static let protection: CFString = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
  }

  @Injected(\.secretManager) private var secretManager: SecretManagerProtocol
  @Injected(\.appPepperKeyRepository) private var appPepperKeyRepository: AppPepperKeyRepositoryProtocol
  @Injected(\.appPinSaltLength) private var appPinSaltLength: Int
  @Injected(\.pepperKeyInitialVectorLength) private var pepperKeyInitialVectorLength: Int

  private func setPepperInitialVector(_ initialVector: Data) throws {
    let query = try QueryBuilder()
      .setService(Key.authenticationService)
      .setAccessControlFlags([])
      .setProtection(SecretConfiguration.protection)
      .build()

    try secretManager.set(initialVector, forKey: Key.pepperInitialVectorIdentifier, query: query)
  }

  private func getPepperInitialVector() throws -> Data {
    let query = try QueryBuilder()
      .setService(Key.authenticationService)
      .build()

    guard let data = secretManager.data(forKey: Key.pepperInitialVectorIdentifier, query: query) else {
      throw Error.unavailableData
    }

    return data
  }

  private func setPinSalt(_ salt: Data) throws {
    let query = try QueryBuilder()
      .setService(Key.authenticationService)
      .setAccessControlFlags([])
      .setProtection(SecretConfiguration.protection)
      .build()

    try secretManager.set(salt, forKey: Key.saltAppPinIdentifier, query: query)
  }

  private func getPinSalt() throws -> Data {
    let query = try QueryBuilder()
      .setService(Key.authenticationService)
      .build()

    guard let data = secretManager.data(forKey: Key.saltAppPinIdentifier, query: query) else {
      throw Error.unavailableData
    }

    return data
  }
}
