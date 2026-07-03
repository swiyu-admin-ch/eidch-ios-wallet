import Factory
import XCTest
@testable import BITCrypto
@testable import BITJWT
@testable import BITOpenID
@testable import BITTestingCore
@testable import BITVault

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

final class DPoPGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()

    sha256HasherSpy = HashableSpy()
    jwsEncoderMock = JWSEncoderMock()

    Container.shared.sha256Hasher.register { self.sha256HasherSpy }
    Container.shared.jwsEncoder.register { self.jwsEncoderMock }

    sha256HasherSpy.hashReturnValue = Data([0xFB, 0xFF])
    jwsEncoderMock.encodeUsingReturnValue = Self.mockProof.data(using: .utf8)!

    generator = DPoPGenerator()
  }

  func testGenerate_success() throws {
    let proof = try generator.generate(
      method: "post",
      url: Self.url,
      keyPair: mockKeyPair,
      nonce: "dpop-nonce",
      accessToken: "access-token",
      keyAttestationJWS: nil)

    XCTAssertEqual(proof, Self.mockProof)
    XCTAssertEqual(jwsEncoderMock.receivedKeyPair, mockKeyPair)
    XCTAssertEqual(jwsEncoderMock.receivedValue?.httpMethod, "POST")
    XCTAssertEqual(jwsEncoderMock.receivedValue?.httpTargetURI, "https://issuer.example.com/token")
    XCTAssertEqual(jwsEncoderMock.receivedValue?.nonce, "dpop-nonce")
    XCTAssertEqual(jwsEncoderMock.receivedValue?.accessTokenHash, "-_8=")
    XCTAssertEqual(jwsEncoderMock.receivedAdditionalHeaderParameters["profile_version"] as? String, "swiss-profile-issuance:1.0.0")
    XCTAssertEqual(sha256HasherSpy.hashReceivedData, Data("access-token".utf8))
  }

  func testGenerate_withKeyAttestation_setsHeaderParameter() throws {
    _ = try generator.generate(
      method: "post",
      url: Self.url,
      keyPair: mockKeyPair,
      nonce: nil,
      accessToken: nil,
      keyAttestationJWS: "attestation-jws")

    XCTAssertEqual(jwsEncoderMock.receivedAdditionalHeaderParameters["key_attestation"] as? String, "attestation-jws")
  }

  func testGenerate_withoutAccessToken_doesNotHashToken() throws {
    _ = try generator.generate(
      method: "post",
      url: Self.url,
      keyPair: mockKeyPair,
      nonce: nil,
      accessToken: nil,
      keyAttestationJWS: nil)

    XCTAssertEqual(sha256HasherSpy.hashCallsCount, 0)
    XCTAssertNil(jwsEncoderMock.receivedValue?.accessTokenHash)
  }

  func testGenerate_normalizesTargetURI() throws {
    _ = try generator.generate(
      method: "post",
      url: XCTUnwrap(URL(string: "https://issuer.example.com/token?query=value#fragment")),
      keyPair: mockKeyPair,
      nonce: nil,
      accessToken: nil,
      keyAttestationJWS: nil)

    XCTAssertEqual(jwsEncoderMock.receivedValue?.httpTargetURI, "https://issuer.example.com/token")
  }

  func testGenerate_usesIntegralIssuedAt() throws {
    _ = try generator.generate(
      method: "post",
      url: Self.url,
      keyPair: mockKeyPair,
      nonce: nil,
      accessToken: nil,
      keyAttestationJWS: nil)

    let issuedAt = try XCTUnwrap(jwsEncoderMock.receivedValue?.issuedAt?.timeIntervalSince1970)
    XCTAssertEqual(issuedAt.rounded(.towardZero), issuedAt)
  }

  func testGenerate_invalidEncoding_throws() throws {
    jwsEncoderMock.encodeUsingReturnValue = Data([0xFF])

    XCTAssertThrowsError(
      try generator.generate(
        method: "post",
        url: Self.url,
        keyPair: mockKeyPair,
        nonce: nil,
        accessToken: nil,
        keyAttestationJWS: nil))
    { error in
      guard case DPoPGeneratorError.invalidEncoding = error else {
        return XCTFail("Expected invalidEncoding")
      }
    }
  }

  // MARK: Private

  private static let mockProof = "proof"
  private static let url = URL(string: "https://issuer.example.com/token?query=value#fragment")!

  private let mockKeyPair = VaultKeyPair.Mock.ES256

  private var generator: DPoPGenerator!
  private var jwsEncoderMock: JWSEncoderMock<DPoPJWT>!
  private var sha256HasherSpy: HashableSpy!
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
