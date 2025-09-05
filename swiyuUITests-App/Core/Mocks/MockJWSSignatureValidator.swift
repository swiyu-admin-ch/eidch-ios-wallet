import BITJWT
import Foundation

struct MockJWSSignatureValidator: JWSSignatureValidatorProtocol {

  init(_ value: Bool = false) {
    self.value = value
  }

  private var value: Bool

  func validate(_ jws: JWS<some Codable & Equatable>, issuerDid: String) async throws -> Bool {
    value
  }
}
