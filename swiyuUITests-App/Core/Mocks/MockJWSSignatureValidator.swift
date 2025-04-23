import BITJWT
import Foundation

struct MockJWSSignatureValidator: JWSSignatureValidatorProtocol {

  init(_ value: Bool = false) {
    self.value = value
  }

  private var value: Bool

  func validate(_ jws: JWSValidatable, did: String) async throws -> Bool {
    value
  }
}
