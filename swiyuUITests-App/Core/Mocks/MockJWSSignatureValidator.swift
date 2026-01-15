import BITJWT
import Foundation

struct MockJWSSignatureValidator: JWSSignatureValidatorProtocol {
  func validate(_ jws: JWS<some JWT>, issuerDid: String) async throws { }
}
