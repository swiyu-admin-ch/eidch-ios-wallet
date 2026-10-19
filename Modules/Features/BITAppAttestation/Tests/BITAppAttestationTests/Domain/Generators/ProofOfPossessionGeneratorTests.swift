import Factory
import XCTest
@testable import BITAppAttestation
@testable import BITCrypto
@testable import BITJsonCanonicalizer
@testable import BITJWT
@testable import BITNetworking
@testable import BITTestingCore
@testable import BITVault

// swiftlint: disable implicitly_unwrapped_optional force_unwrapping force_try

final class ProofOfPossessionGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    registerMocks()
    generator = ProofOfPossessionGenerator()
    createSuccessState()
  }

  func testGenerate_assertParameters_success() async throws {
    let pop = try await generator(
      for: mockBody,
      audience: mockAudience,
      challengeEndpoint: mockChallengeEndpoint,
      clientAttestation: mockClientAttestation)

    XCTAssertEqual(pop, mockClientAttestationProofOfPossession)
    XCTAssertEqual(pop.payload.nonce, mockChallenge.challenge)
    XCTAssertEqual(pop.payload.audience, mockAudience)
    XCTAssertEqual(pop.payload.issuer, mockClientAttestation.payload.subject)

    XCTAssertEqual(urlSession.dataFromReceivedUrl, mockChallengeEndpoint)
    XCTAssertEqual(appAttestationKeyRepository.getForReceivedType, .client)
    XCTAssertEqual(jsonCanonicalizer.canonicalizeDataReceivedData, try JSONEncoder().encode(mockBody))
  }

  func testGenerate_assertCount_success() async throws {
    _ = try await generator(
      for: mockBody,
      audience: mockAudience,
      challengeEndpoint: mockChallengeEndpoint,
      clientAttestation: mockClientAttestation)

    XCTAssertEqual(urlSession.dataFromCallsCount, 1)
    XCTAssertEqual(appAttestationKeyRepository.getForCallsCount, 1)
    XCTAssertEqual(jsonCanonicalizer.canonicalizeDataCallsCount, 1)
  }

  func testGenerate_fetchChallengeFails_throwsError() async throws {
    urlSession.dataFromThrowableError = TestingError.error

    do {
      _ = try await generator(
        for: mockBody,
        audience: mockAudience,
        challengeEndpoint: mockChallengeEndpoint,
        clientAttestation: mockClientAttestation)
      XCTFail("Expected error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testGenerate_getAttestationKeyFails_throwsError() async throws {
    appAttestationKeyRepository.getForThrowableError = TestingError.error

    do {
      _ = try await generator(
        for: mockBody,
        audience: mockAudience,
        challengeEndpoint: mockChallengeEndpoint,
        clientAttestation: mockClientAttestation)
      XCTFail("Expected error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testGenerate_jsonCanonicalizerFails_throwsError() async throws {
    jsonCanonicalizer.canonicalizeDataThrowableError = TestingError.error

    do {
      _ = try await generator(
        for: mockBody,
        audience: mockAudience,
        challengeEndpoint: mockChallengeEndpoint,
        clientAttestation: mockClientAttestation)
      XCTFail("Expected error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let mockBody = "mock_body"
  private let mockAudience = "did:tdw:example.com"
  private let mockClientAttestationProofOfPossession = ClientAttestationProofOfPossession.Mock.sample
  private let mockClientAttestation = ClientAttestationJWT.Mock.sample
  private let mockChallenge = AttestationChallenge.Response.Mock.sample
  private let mockChallengeData = AttestationChallenge.Response.Mock.sampleData
  private let mockSecKey = VaultKeyPair.Mock.ES256
  private let mockChallengeEndpoint = URL(string: "https://mock_challenge_url")!

  private var generator: ProofOfPossessionGenerator!
  private var jwsEncoder: JWSEncoderMock<ClientAttestationProofOfPossessionJWT>!
  private var jsonCanonicalizer: JsonCanonicalizerProtocolSpy!
  private var appAttestationKeyRepository: AppAttestationKeyRepositoryProtocolSpy!
  private var urlSession: URLSessionProtocolSpy!

  private func createSuccessState() {
    jwsEncoder.encodeReturnValue = mockClientAttestationProofOfPossession
    jsonCanonicalizer.canonicalizeDataReturnValue = try! JSONEncoder().encode(mockBody)
    appAttestationKeyRepository.getForReturnValue = mockSecKey
    urlSession.dataFromReturnValue = (mockChallengeData, URLResponse())
  }

  private func registerMocks() {
    let jwsEncoder = JWSEncoderMock<ClientAttestationProofOfPossessionJWT>()
    let jsonCanonicalizer = JsonCanonicalizerProtocolSpy()
    let urlSession = URLSessionProtocolSpy()
    let appAttestationKeyRepository = AppAttestationKeyRepositoryProtocolSpy()
    self.jwsEncoder = jwsEncoder
    self.jsonCanonicalizer = jsonCanonicalizer
    self.urlSession = urlSession
    self.appAttestationKeyRepository = appAttestationKeyRepository

    Container.shared.jwsEncoder.register { jwsEncoder }
    Container.shared.jsonCanonicalizer.register { jsonCanonicalizer }
    Container.shared.appAttestationKeyRepository.register { appAttestationKeyRepository }
    NetworkContainer.shared.urlSession.register { urlSession }
  }
}

// swiftlint: enable implicitly_unwrapped_optional force_unwrapping force_try
