import BITLocalAuthentication
import BITVault
import Factory
import Foundation
import Security

// MARK: - UniquePassphraseRepository

struct UniquePassphraseRepository: UniquePassphraseRepositoryProtocol {

  // MARK: Internal

  func saveUniquePassphrase(_ data: Data, forAuthMethod authMethod: AuthMethod, inContext context: LAContextProtocol) throws {
    let query = try QueryBuilder()
      .setService(Key.authenticationService)
      .setAccessControlFlags(authMethod.accessControlFlags)
      .setProtection(SecretConfiguration.protection)
      .setContext(context)
      .build()

    try secretManager.set(data, forKey: authMethod.identifierKey, query: query)
  }

  func hasUniquePassphraseSaved(forAuthMethod authMethod: AuthMethod) -> Bool {
    do {
      let query = try QueryBuilder()
        .setService(Key.authenticationService)
        .build()

      return secretManager.exists(key: authMethod.identifierKey, query: query)
    } catch {
      return false
    }
  }

  func getUniquePassphrase(forAuthMethod authMethod: AuthMethod, inContext context: LAContextProtocol) throws -> Data {
    let query = try QueryBuilder()
      .setService(Key.authenticationService)
      .setContext(context)
      .build()

    guard let data = secretManager.data(forKey: authMethod.identifierKey, query: query) else {
      throw Error.unavailableData
    }

    return data
  }

  func deleteBiometricUniquePassphrase() throws {
    let query = try QueryBuilder()
      .setService(Key.authenticationService)
      .build()

    try secretManager.removeObject(forKey: AuthMethod.biometric.identifierKey, query: query)
  }

  // MARK: Private

  private enum Key {
    static let authenticationService = "ch.admin.foitt.federal-wallet.authentication"
  }

  private enum Error: Swift.Error {
    case unavailableData
  }

  private enum SecretConfiguration {
    static let protection: CFString = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
  }

  @Injected(\.secretManager) private var secretManager: SecretManagerProtocol
}
