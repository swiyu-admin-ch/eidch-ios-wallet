import Foundation

// MARK: - KeyManager

public struct KeyManager: KeyManagerProtocol {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public func generateKeyPair(withIdentifier identifier: String, algorithm: VaultAlgorithm, options: VaultOption, query: Query?) throws -> SecKey {
    guard let dataIdentifier = identifier.data(using: .utf8) else {
      throw VaultError.identifierCannotBeCasted
    }

    var defaultQuery: [String: Any] = [
      kSecAttrKeyType as String: algorithm.keyType,
      kSecAttrKeySizeInBits as String: algorithm.size,
      kSecPrivateKeyAttrs as String: [
        kSecAttrIsPermanent as String: options.contains(.savePermanently),
        kSecAttrApplicationTag as String: dataIdentifier,
      ],
    ]

    if options.contains(.secureEnclave) && algorithm.canBeUsedForSecureEnclave {
      defaultQuery[kSecAttrTokenID as String] = kSecAttrTokenIDSecureEnclave

      var privateKeyAttributes = defaultQuery[kSecPrivateKeyAttrs as String] as? [String: Any]
      privateKeyAttributes?[kSecAttrAccessControl as String] = try SecAccessControl.create()

      defaultQuery[kSecPrivateKeyAttrs as String] = privateKeyAttributes
    }

    var userQuery = query ?? defaultQuery
    userQuery.mergeWith(defaultQuery)

    var error: Unmanaged<CFError>?
    guard let privateKey = SecKeyCreateRandomKey(userQuery as CFDictionary, &error) else {
      if let keyGenError = error?.takeRetainedValue() {
        throw VaultError.keyGenerationError(reason: "Key generation failed with error: \(keyGenError)")
      }
      throw VaultError.keyGenerationError(reason: "Unknown error during key generation.")
    }

    return privateKey
  }

  public func getPrivateKey(withIdentifier identifier: String, algorithm: VaultAlgorithm, query: Query?) throws -> SecKey {
    guard let dataIdentifier = identifier.data(using: .utf8) else {
      throw VaultError.identifierCannotBeCasted
    }

    let defaultQuery: [String: Any] = [
      kSecClass as String: kSecClassKey,
      kSecAttrApplicationTag as String: dataIdentifier,
      kSecAttrKeyType as String: algorithm.keyType,
      kSecReturnRef as String: true,
    ]

    var userQuery = query ?? defaultQuery
    userQuery.mergeWith(defaultQuery)

    var item: CFTypeRef?
    let status = SecItemCopyMatching(userQuery as CFDictionary, &item)

    guard status == errSecSuccess, item != nil else {
      throw VaultError.keyRetrievalError
    }

    // swiftlint:disable force_cast
    // Force cast disabled because we have to cast it this way at this point. a guard doesn't work unfortunately...
    return item as! SecKey
    // swiftlint: enable force_cast
  }

  public func deleteKeyPair(withIdentifier identifier: String, algorithm: VaultAlgorithm) throws {
    guard let dataIdentifier = identifier.data(using: .utf8) else {
      throw VaultError.identifierCannotBeCasted
    }

    let defaultQuery: [String: Any] = [
      kSecClass as String: kSecClassKey,
      kSecAttrApplicationTag as String: dataIdentifier,
      kSecAttrKeyType as String: algorithm.keyType,
    ]

    let status = SecItemDelete(defaultQuery as CFDictionary)
    guard [errSecSuccess, errSecItemNotFound].contains(status) else {
      throw VaultError.keyDeletionError
    }
  }

  public func getPublicKey(withIdentifier identifier: String, algorithm: VaultAlgorithm, query: Query?) throws -> SecKey {
    let privateKey = try getPrivateKey(withIdentifier: identifier, algorithm: algorithm, query: query)
    return try getPublicKey(for: privateKey)
  }

  public func getPublicKey(for privateKey: SecKey) throws -> SecKey {
    guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
      throw VaultError.publicKeyRetrievalError
    }
    return publicKey
  }
}
