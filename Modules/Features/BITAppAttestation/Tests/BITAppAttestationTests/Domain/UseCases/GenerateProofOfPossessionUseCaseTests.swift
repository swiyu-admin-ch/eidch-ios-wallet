// swiftlint: disable implicitly_unwrapped_optional force_unwrapping force_try
import Factory
import XCTest
@testable import BITAppAttestation
@testable import BITCrypto
@testable import BITJsonCanonicalizer
@testable import BITJWT
@testable import BITTestingCore

final class GenerateProofOfPossessionUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    registerMocks()
    useCase = GenerateProofOfPossessionUseCase()
    createSuccessState()
  }

  func testExecute_success() async throws {
    let result = try await useCase.execute(for: mockClientAttestation, challenge: mockChallenge.challenge, audience: mockAudience, body: mockBody, signingKey: mockKeyPair)

    XCTAssertEqual(result, mockClientAttestationProofOfPossession)
    XCTAssertEqual(result.payload.nonce, mockChallenge.challenge)
    XCTAssertEqual(result.payload.audience, mockAudience)
    XCTAssertEqual(jsonCanonicalizer.canonicalizeDataCallsCount, 1)
    XCTAssertEqual(jsonCanonicalizer.canonicalizeDataReceivedData, try! JSONEncoder().encode(mockBody))
  }

  func testExecute_jsonCanonicalizerFails_throwsError() async throws {
    jsonCanonicalizer.canonicalizeDataThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: mockClientAttestation, challenge: mockChallenge.challenge, audience: mockAudience, body: mockBody, signingKey: mockKeyPair)
      XCTFail("Expected error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let mockBody = "mock_body"
  private let mockAudience = "did:tdw:example.com"
  private let mockClientAttestation = ClientAttestationPayload.Mock.sample
  private let mockClientAttestationProofOfPossession = ClientAttestationProofOfPossession.Mock.sample
  private let mockChallenge = AttestationChallenge.Response.Mock.sample
  private let mockKeyPair = KeyPair(algorithm: "ES256", privateKey: SecKeyTestsHelper.createPrivateKey(size: 256))

  private var useCase: GenerateProofOfPossessionUseCase!
  private var jwsEncoder: JWSEncoderMock<ClientAttestationProofOfPossessionPayload>!
  private var jsonCanonicalizer: JsonCanonicalizerProtocolSpy!

  private func createSuccessState() {
    jwsEncoder.encodeReturnValue = mockClientAttestationProofOfPossession
    jsonCanonicalizer.canonicalizeDataReturnValue = try! JSONEncoder().encode(mockBody)
  }

  private func registerMocks() {
    jwsEncoder = JWSEncoderMock()
    jsonCanonicalizer = JsonCanonicalizerProtocolSpy()

    Container.shared.jwsEncoder.register { self.jwsEncoder }
    Container.shared.jsonCanonicalizer.register { self.jsonCanonicalizer }
  }
}

// swiftlint: enable implicitly_unwrapped_optional force_unwrapping force_try
