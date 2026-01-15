import Foundation

// MARK: - KeyManager

public struct KeyManager: KeyManagerProtocol {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  public func generateKeyPair(withIdentifier identifier: String, algorithm: VaultAlgorithm, options: VaultOptions, query: Query?) throws -> VaultKeyPair {
    guard let dataIdentifier = identifier.data(using: .utf8) else {
      throw VaultError.identifierCannotBeCasted(identifier: identifier)
    }

    var privateKeyAttributes: [String: Any] = [
      kSecAttrIsPermanent as String: options.contains(.savePermanently),
      kSecAttrApplicationTag as String: dataIdentifier,
    ]

    var defaultQuery: [String: Any] = [
      kSecAttrKeyType as String: algorithm.keyType,
      kSecAttrKeySizeInBits as String: algorithm.size,
      kSecPrivateKeyAttrs as String: privateKeyAttributes,
    ]

    if options.contains(.secureEnclave) && algorithm.canBeUsedForSecureEnclave {
      defaultQuery[kSecAttrTokenID as String] = kSecAttrTokenIDSecureEnclave
      privateKeyAttributes[kSecAttrAccessControl as String] = try SecAccessControl.create()
      defaultQuery[kSecPrivateKeyAttrs as String] = privateKeyAttributes
    }

    var finalQuery = query ?? defaultQuery
    finalQuery.mergeWith(defaultQuery)

    var error: Unmanaged<CFError>?
    guard let privateKey = SecKeyCreateRandomKey(finalQuery as CFDictionary, &error) else {
      if let keyGenError = error?.takeRetainedValue() {
        let diagnostic = DiagnosticErrorHelper.diagnostic(for: finalQuery, error: keyGenError)
        throw VaultError.keyGenerationError(reason: diagnostic)
      }
      throw VaultError.keyGenerationError(reason: "Unknown error during key generation.")
    }

    return VaultKeyPair(identifier: identifier, privateKey: privateKey, algorithm: algorithm, options: options)
  }

  public func getKeyPair(withIdentifier identifier: String, algorithm: VaultAlgorithm, query: Query?) throws -> VaultKeyPair {
    guard let dataIdentifier = identifier.data(using: .utf8) else {
      throw VaultError.identifierCannotBeCasted(identifier: identifier)
    }

    let defaultQuery: [String: Any] = [
      kSecClass as String: kSecClassKey,
      kSecAttrApplicationTag as String: dataIdentifier,
      kSecAttrKeyType as String: algorithm.keyType,
      kSecReturnRef as String: true,
    ]

    var finalQuery = query ?? defaultQuery
    finalQuery.mergeWith(defaultQuery)

    var item: CFTypeRef?
    let status = SecItemCopyMatching(finalQuery as CFDictionary, &item)

    guard status == errSecSuccess, item != nil else {
      throw VaultError.keyRetrievalError(reason: "Received OSStatus: \(status)")
    }

    // swiftlint:disable force_cast
    // Force cast disabled because we have to cast it this way at this point. a guard doesn't work unfortunately...
    let privateKey = item as! SecKey
    // swiftlint: enable force_cast
    return VaultKeyPair(identifier: identifier, privateKey: privateKey, algorithm: algorithm)
  }

  public func deleteKeyPair(withIdentifier identifier: String, algorithm: VaultAlgorithm) throws {
    guard let dataIdentifier = identifier.data(using: .utf8) else {
      throw VaultError.identifierCannotBeCasted(identifier: identifier)
    }

    let defaultQuery: [String: Any] = [
      kSecClass as String: kSecClassKey,
      kSecAttrApplicationTag as String: dataIdentifier,
      kSecAttrKeyType as String: algorithm.keyType,
    ]

    let status = SecItemDelete(defaultQuery as CFDictionary)
    guard [errSecSuccess, errSecItemNotFound].contains(status) else {
      throw VaultError.keyDeletionError(reason: "Received OSStatus: \(status)")
    }
  }

  public func getExternalRepresentation(of privateKey: SecKey) throws -> (rawPublicKey: Data, rawPrivateKey: Data) {
    var error: Unmanaged<CFError>?
    guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
      throw VaultError.publicKeyRetrievalError
    }

    guard let rawPublicKey = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
      throw VaultError.keyRetrievalError(reason: error?.takeRetainedValue().localizedDescription ?? "Unknown error")
    }

    guard let rawPrivateKey = SecKeyCopyExternalRepresentation(privateKey, &error) as Data? else {
      throw VaultError.keyRetrievalError(reason: error?.takeRetainedValue().localizedDescription ?? "Unknown error")
    }
    return (rawPublicKey, rawPrivateKey)
  }
}
