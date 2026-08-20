import JWSETKit

extension JSONWebKeyEncryptionAlgorithm {

  // MARK: Lifecycle

  init(from jwk: JWK) throws {
    guard let alg = jwk.alg else {
      throw KeyManagementAlgorithmError.notFound
    }

    let algorithm = JSONWebKeyEncryptionAlgorithm(rawValue: alg)
    guard algorithm.keyType != nil else {
      throw KeyManagementAlgorithmError.creationError
    }
    self = algorithm
  }

  // MARK: Internal

  enum KeyManagementAlgorithmError: Error {
    case notFound
    case creationError
  }
}
