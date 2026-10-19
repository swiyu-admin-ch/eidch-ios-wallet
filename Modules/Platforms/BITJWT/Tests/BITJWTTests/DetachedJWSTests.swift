import Foundation
import Testing
@testable import BITJWT

struct DetachedJWSTests {

  @Test
  func init_detachedCompactSerialization_exposesHeader() throws {
    let rawJWS = try DetachedJWS.Mock.rawJWS()

    let detachedJWS = try DetachedJWS(rawJWS: rawJWS)

    #expect(detachedJWS.rawJWS == rawJWS)
    #expect(detachedJWS.header.algorithm == .ES256)
    #expect(detachedJWS.header.type == "JOSE")
    #expect(detachedJWS.header.keyIdentifier == DetachedJWS.Mock.keyIdentifier)
  }

  @Test(arguments: ["", "not-a-jws", "eyJhbGciOiJFUzI1NiJ9.signature"])
  func init_malformedCompactSerialization_throwsDecodingError(rawJWS: String) throws {
    #expect(throws: DecodingError.self) {
      try DetachedJWS(rawJWS: rawJWS)
    }
  }

  @Test
  func init_unsupportedAlgorithm_throwsAlgorithmNotFound() throws {
    let rawJWS = try DetachedJWS.Mock.rawJWS(algorithm: "RS256")

    #expect(throws: JWSHeaderError.algorithmNotFound) {
      try DetachedJWS(rawJWS: rawJWS)
    }
  }
}
