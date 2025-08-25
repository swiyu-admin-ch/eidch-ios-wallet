import BITAppAuth
import BITLocalAuthentication
import BITVault
import Factory
import Foundation
import Spyable

// MARK: - CredentialKeyRepositoryProtocol

@Spyable
protocol CredentialKeyRepositoryProtocol {
  func create(algorithm: String, isHardwareBound: Bool) throws -> VaultKeyPair
  func delete(_ keyPair: VaultKeyPair) throws
}

// MARK: - CredentialKeyRepository

struct CredentialKeyRepository: CredentialKeyRepositoryProtocol {

  // MARK: Internal

  enum CredentialKeyRepositoryError: Error {
    case invalidAlgorithm
  }

  func create(algorithm: String, isHardwareBound: Bool) throws -> VaultKeyPair {
    guard
      userSession.isLoggedIn,
      let context = userSession.context

    else {
      throw UserSessionError.notLoggedIn
    }

    let options: VaultOptions = isHardwareBound ? [.secureEnclavePermanently] : [.savePermanently]

    let query = try QueryBuilder()
      .setAccessControlFlags(options.secAccessControl)
      .setProtection(protection)
      .setContext(context)
      .build()

    guard let vaultAlgorithm = VaultAlgorithm(rawValue: algorithm) else {
      throw CredentialKeyRepositoryError.invalidAlgorithm
    }

    return try keyManager.generateKeyPair(
      withIdentifier: UUID().uuidString,
      algorithm: vaultAlgorithm,
      options: options,
      query: query)
  }

  func delete(_ keyPair: VaultKeyPair) throws {
    try keyManager.deleteKeyPair(withIdentifier: keyPair.identifier, algorithm: keyPair.algorithm)
  }

  // MARK: Private

  private let protection: CFString = kSecAttrAccessibleWhenUnlockedThisDeviceOnly

  @Injected(\.keyManager) private var keyManager: KeyManagerProtocol
  @Injected(\.userSession) private var userSession: Session
}
