import JOSESwift

extension JOSESwift.KeyManagementAlgorithm {

  // MARK: Lifecycle

  init(from jwk: JWK) throws {
    guard let alg = jwk.alg else {
      throw KeyManagementAlgorithmError.notFound
    }

    guard let algorithm = JOSESwift.KeyManagementAlgorithm(rawValue: alg) else {
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
