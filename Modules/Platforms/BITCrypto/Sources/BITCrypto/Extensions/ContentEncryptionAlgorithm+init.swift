import JWSETKit

extension JSONWebContentEncryptionAlgorithm {

  init(from encryptionAlgorithm: EncryptionAlgorithm) throws {
    switch encryptionAlgorithm {
    case .A128GCM:
      self = .aesEncryptionGCM128
    case .A256GCM:
      self = .aesEncryptionGCM256
    }
  }
}
