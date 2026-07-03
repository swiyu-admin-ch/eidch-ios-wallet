import BITAppAuth
import BITVault
import Factory
import Foundation
import Spyable

// MARK: - IssuanceDPoPKeyRepositoryProtocol

@Spyable
public protocol IssuanceDPoPKeyRepositoryProtocol {
  func create(isHardwareBound: Bool) throws -> VaultKeyPair
  func delete(_ keyPair: VaultKeyPair) throws
}

// MARK: - IssuanceDPoPKeyRepository

struct IssuanceDPoPKeyRepository: IssuanceDPoPKeyRepositoryProtocol {

  // MARK: Internal

  func create(isHardwareBound: Bool) throws -> VaultKeyPair {
    let options = vaultOptions(isHardwareBound: isHardwareBound)
    let query = try createQuery(options: options)

    return try keyManager.generateKeyPair(
      withIdentifier: UUID().uuidString,
      algorithm: .eciesEncryptionStandardVariableIVX963SHA256AESGCM,
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

  private func createQuery(options: VaultOptions) throws -> Query {
    guard
      userSession.isLoggedIn,
      let context = userSession.context
    else {
      userSession.endSession()
      throw UserSessionError.notLoggedIn
    }

    return try QueryBuilder()
      .setAccessControlFlags(options.secAccessControl)
      .setProtection(protection)
      .setContext(context)
      .build()
  }

  private func vaultOptions(isHardwareBound: Bool) -> VaultOptions {
    isHardwareBound ? [.secureEnclavePermanently] : [.savePermanently]
  }
}
