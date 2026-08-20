import Factory
import Foundation
import Testing
@testable import BITCrypto
@testable import BITJWT
@testable import BITOpenID
@testable import BITTestingCore
@testable import BITVault

struct DPoPGeneratorTests {

  // MARK: Lifecycle

  init() throws {
    let sha256HasherSpy = HashableSpy()
    sha256HasherSpy.hashReturnValue = Data([0xFB, 0xFF])
    self.sha256HasherSpy = sha256HasherSpy

    let jwsEncoderMock = JWSEncoderMock<DPoPJWT>()
    jwsEncoderMock.encodeReturnValue = DPoPJWT.Mock.sample
    self.jwsEncoderMock = jwsEncoderMock

    url = try #require(URL(string: "https://issuer.example.com/token"))

    Container.shared.sha256Hasher.register { sha256HasherSpy }
    Container.shared.jwsEncoder.register { jwsEncoderMock }

    generator = DPoPGenerator()
  }

  // MARK: Internal

  @Test
  func generate_success() throws {
    let proof = try generator.generate(method: "post", url: url, keyPair: mockKeyPair, nonce: "dpop-nonce", accessToken: "access-token", additionalHeaderParameters: mockAdditionalParameter)

    #expect(proof == mockProof)
    #expect(jwsEncoderMock.receivedKeyPair == mockKeyPair)
    #expect(jwsEncoderMock.receivedValue?.httpMethod == "POST")
    #expect(jwsEncoderMock.receivedValue?.httpTargetURI == "https://issuer.example.com/token")
    #expect(jwsEncoderMock.receivedValue?.nonce == "dpop-nonce")
    #expect(jwsEncoderMock.receivedValue?.accessTokenHash == "-_8")

    if let parameter = try #require(jwsEncoderMock.receivedAdditionalHeaderParameters["profile_version"] as? String) {
      #expect(parameter == "swiss-profile-issuance:1.0.0")
    }

    #expect(sha256HasherSpy.hashReceivedData == Data("access-token".utf8))
  }

  @Test
  func generate_withKeyAttestation_setsHeaderParameter() throws {
    _ = try generator.generate(method: "post", url: url, keyPair: mockKeyPair, additionalHeaderParameters: ["key_attestation": "attestation-jws"])
    #expect((jwsEncoderMock.receivedAdditionalHeaderParameters["key_attestation"] as? String) != nil, "attestation-jws")
  }

  @Test
  func generate_withoutAccessToken_doesNotHashToken() throws {
    _ = try generator.generate(method: "post", url: url, keyPair: mockKeyPair, accessToken: nil)

    #expect(!sha256HasherSpy.hashCalled)
    #expect(jwsEncoderMock.receivedValue?.accessTokenHash == nil)
  }

  @Test
  func generate_normalizesTargetURI() throws {
    let url = try #require(URL(string: "https://issuer.example.com/token?query=value#fragment"))
    _ = try generator.generate(method: "post", url: url, keyPair: mockKeyPair)

    #expect(jwsEncoderMock.receivedValue?.httpTargetURI == "https://issuer.example.com/token")
  }

  @Test
  func generate_usesIntegralIssuedAt() throws {
    let proof = try generator.generate(method: "post", url: url, keyPair: mockKeyPair)
    #expect(proof.payload.issuedAt == mockProof.payload.issuedAt)
  }

  // MARK: Private

  private let mockProof = DPoPJWT.Mock.sample
  private let url: URL

  private let mockKeyPair = VaultKeyPair.Mock.ES256
  private let mockAdditionalParameter = ["profile_version": "swiss-profile-issuance:1.0.0"]

  private var generator: DPoPGenerator
  private var sha256HasherSpy: HashableSpy
  private var jwsEncoderMock: JWSEncoderMock<DPoPJWT>
}
