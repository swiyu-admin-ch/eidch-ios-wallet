import JOSESwift

extension ContentEncryptionAlgorithm {

  // MARK: Lifecycle

  init(from encryptionAlgorithm: EncryptionAlgorithm) throws {
    guard let algorithm = ContentEncryptionAlgorithm(rawValue: encryptionAlgorithm.rawValue) else {
      throw ContentEncryptionAlgorithmError.creationError
    }
    self = algorithm
  }

  // MARK: Internal

  enum ContentEncryptionAlgorithmError: Error {
    case creationError
  }
}
