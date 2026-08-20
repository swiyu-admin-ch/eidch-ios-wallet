import JWSETKit

extension JSONWebContentEncryptionAlgorithm {

  // MARK: Lifecycle

  init(from encryptionAlgorithm: EncryptionAlgorithm) throws {
    switch encryptionAlgorithm {
    case .A128GCM:
      self = .aesEncryptionGCM128
    case .A256GCM:
      self = .aesEncryptionGCM256
    }
  }

  // MARK: Internal

  enum ContentEncryptionAlgorithmError: Error {
    case creationError
  }
}
