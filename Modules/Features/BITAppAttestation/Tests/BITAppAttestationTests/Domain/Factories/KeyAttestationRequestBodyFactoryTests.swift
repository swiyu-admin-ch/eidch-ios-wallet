import XCTest
@testable import BITAppAttestation
@testable import BITCrypto
@testable import BITVault

final class KeyAttestationRequestBodyTests: XCTestCase {

  func testInitWithKeyPair_success_returnsBindingKeyFromPublicKey() throws {
    let keyPair = VaultKeyPair.Mock.ES256

    let result = try KeyAttestationRequestBody(keyPair: keyPair)

    let expectedJwk = try JWK(from: XCTUnwrap(keyPair.publicKey))
    XCTAssertEqual(result.bindingKey.jwk, expectedJwk)
  }
}
