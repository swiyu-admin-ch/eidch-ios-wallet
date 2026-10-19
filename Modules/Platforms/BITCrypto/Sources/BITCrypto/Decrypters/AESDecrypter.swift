import CryptoKit
import Foundation
import Spyable

// MARK: - Decryptable

@Spyable
protocol Decryptable: Sendable {
  func decrypt(_ data: Data, withSymmetricKey key: SymmetricKeyProtocol, additionalAuthenticatedData: Data?) throws -> Data
}

// MARK: - DecrypterError

enum DecrypterError: Error {
  case invalidSymmetricKey
}

// MARK: - AESDecrypter

struct AESDecrypter: Decryptable {

  // MARK: Public

  func decrypt(_ data: Data, withSymmetricKey key: SymmetricKeyProtocol, additionalAuthenticatedData: Data?) throws -> Data {
    guard let symmetricKey = key as? SymmetricKey else {
      throw DecrypterError.invalidSymmetricKey
    }

    let sealedBox = try AES.GCM.SealedBox(combined: data)

    if let additionalAuthenticatedData {
      return try AES.GCM.open(sealedBox, using: symmetricKey, authenticating: additionalAuthenticatedData)
    }

    return try AES.GCM.open(sealedBox, using: symmetricKey)
  }
}
