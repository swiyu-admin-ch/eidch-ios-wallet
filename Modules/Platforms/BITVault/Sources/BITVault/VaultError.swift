import Foundation

public enum VaultError: Error, LocalizedError {
  case keyGenerationError(reason: String)
  case keyRetrievalError(reason: String)
  case keyDeletionError(reason: String)
  case identifierCannotBeCasted(identifier: String)
  case publicKeyRetrievalError
  case encryptionError(String)
  case decryptionError(String)
  case algorithmNotSupported
  case toDataFailed(String)
  case jwkCreationError
  case jwtCreationError(String)
  case contextApplicationPasswordNotSet
  case secretSavingError(reason: String)
  case secretDeletingError(reason: String)
  case secretRetrievalError(reason: String)
  case invalidSecret

  // MARK: Public

  public var errorDescription: String? {
    switch self {
    case .keyGenerationError(let reason):
      NSLocalizedString("Failed to generate a key: \(reason)", comment: "Key generation error")
    case .keyRetrievalError(let reason):
      NSLocalizedString("Failed to retrieve the key: \(reason)", comment: "Key retrieval error")
    case .keyDeletionError(let reason):
      NSLocalizedString("Failed to delete the key: \(reason)", comment: "Key deletion error")
    case .identifierCannotBeCasted(let identifier):
      NSLocalizedString("Failed to cast identifier '\(identifier)' to utf8", comment: "Identifier cannot be casted")
    case .publicKeyRetrievalError:
      NSLocalizedString("Failed to retrieve the public key.", comment: "Public key retrieval error")
    case .encryptionError(let reason):
      NSLocalizedString("Encryption failed: \(reason)", comment: "Encryption error")
    case .decryptionError(let reason):
      NSLocalizedString("Decryption failed: \(reason)", comment: "Decryption error")
    case .algorithmNotSupported:
      NSLocalizedString("The provided algorithm is not supported.", comment: "Unsupported algorithm error")
    case .toDataFailed(let reason):
      NSLocalizedString("Casting to Data failed: \(reason)", comment: "To Data type error")
    case .jwkCreationError:
      NSLocalizedString("Failed to generate a JWK", comment: "JWK creation error")
    case .jwtCreationError(let reason):
      NSLocalizedString("Failed to generate a JWS: \(reason)", comment: "JWS creation error")
    case .contextApplicationPasswordNotSet:
      NSLocalizedString("Missing application password", comment: "Context .applicationPassword not set")
    case .secretSavingError(let reason):
      NSLocalizedString("Failed to save a secret: \(reason)", comment: "Secret saving error")
    case .secretDeletingError(let reason):
      NSLocalizedString("Failed to delete a secret: \(reason)", comment: "Secret deleting error")
    case .secretRetrievalError(let reason):
      NSLocalizedString("Failed to retrieve a secret: \(reason)", comment: "Secret retrieval error")
    case .invalidSecret:
      NSLocalizedString("The secret retrieved is invalid", comment: "Secret retrieval error")
    }
  }
}
