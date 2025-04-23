import Foundation
import JOSESwift

extension JOSESwift.JWSHeader {

  init(algorithm: SignatureAlgorithm, kid: String? = nil, type: String) {
    self.init(algorithm: algorithm)
    self.kid = kid
    typ = type
  }

}
