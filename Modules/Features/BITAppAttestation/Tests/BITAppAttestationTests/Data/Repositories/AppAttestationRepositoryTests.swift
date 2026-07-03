import BITNetworking
import Factory
import XCTest
@testable import BITAppAttestation
@testable import BITCrypto
@testable import BITJWT
@testable import BITLocalAuthentication
@testable import BITTestingCore
@testable import BITVault

// swiftlint: disable implicitly_unwrapped_optional force_unwrapping

final class AppAttestationRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.reset()
    NetworkContainer.shared.reset()
    NetworkContainer.shared.stubClosure.register { { _ in .immediate } }

    registerMocks()
    repository = AppAttestationRepository()
    createSuccessState()
  }

  // MARK: - FetchChallenge

  func testFetchChallenge_success() async throws {
    let expectedResponse = AttestationChallenge.Response.Mock.sample.challenge
    mockResponse(code: 200, data: AttestationChallenge.Response.Mock.sampleData)

    let response = try await repository.fetchChallenge()

    XCTAssertEqual(response, expectedResponse)
  }

  func testFetchChallenge_failure() async throws {
    mockResponse(code: 500)

    do {
      _ = try await repository.fetchChallenge()
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual((error as? NetworkError)?.status, .internalServerError)
    }
  }

  func testFetchChallenge_timeout_throwsTimeout() async throws {
    mockResponse(code: 408)

    do {
      _ = try await repository.fetchChallenge()
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? AppAttestationRepositoryError, .timeout)
    }
  }

  func testFetchChallenge_teapot_throwsServiceDeactivated() async throws {
    mockResponse(code: 418)

    do {
      _ = try await repository.fetchChallenge()
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? AppAttestationRepositoryError, .serviceDeactivated)
    }
  }

  func testFetchChallenge_serviceUnavailable_throwsServiceDeactivated() async throws {
    mockResponse(code: 503)

    do {
      _ = try await repository.fetchChallenge()
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? AppAttestationRepositoryError, .serviceDeactivated)
    }
  }

  // MARK: - FetchClientAttestation

  func testFetchClientAttestation_success() async throws {
    let jwsDecoderMock = JWSDecoderMock(jwt: ClientAttestationJWT.Mock.sampleJWT, rawPayload: "rawPayload")
    Container.shared.jwsDecoder.register { jwsDecoderMock }

    repository = AppAttestationRepository()

    let expectedResponse = ClientAttestationJWT.Mock.sample
    mockResponse(code: 200, data: ClientAttestationResponse.Mock.sampleData)

    let response = try await repository.fetchClientAttestation(mockClientAttestationRequestBody)

    XCTAssertEqual(response.payload, expectedResponse.payload)
  }

  func testFetchClientAttestation_failure() async throws {
    mockResponse(code: 500)

    do {
      _ = try await repository.fetchClientAttestation(mockClientAttestationRequestBody)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual((error as? NetworkError)?.status, .internalServerError)
    }
  }

  func testFetchClientAttestation_timeout_throwsTimeout() async throws {
    mockResponse(code: 408)

    do {
      _ = try await repository.fetchClientAttestation(mockClientAttestationRequestBody)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? AppAttestationRepositoryError, .timeout)
    }
  }

  func testFetchClientAttestation_teapot_throwsServiceDeactivated() async throws {
    mockResponse(code: 418)

    do {
      _ = try await repository.fetchClientAttestation(mockClientAttestationRequestBody)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? AppAttestationRepositoryError, .serviceDeactivated)
    }
  }

  func testFetchClientAttestation_serviceUnavailable_throwsServiceDeactivated() async throws {
    mockResponse(code: 503)

    do {
      _ = try await repository.fetchClientAttestation(mockClientAttestationRequestBody)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? AppAttestationRepositoryError, .serviceDeactivated)
    }
  }

  // MARK: - FetchKeyAttestation

  func testFetchKeyAttestation_success() async throws {
    let jwsDecoderMock = JWSDecoderMock(jwt: KeyAttestationJWT.Mock.sampleJWT, rawPayload: "rawPayload")
    Container.shared.jwsDecoder.register { jwsDecoderMock }

    repository = AppAttestationRepository()

    let expectedResponse = KeyAttestationJWT.Mock.sample
    mockResponse(code: 200, data: KeyAttestationResponse.Mock.sampleData)

    let response = try await repository.fetchKeyAttestation(body: mockKeyAttestationRequestBody, clientAttestation: mockClientAttestation)

    XCTAssertEqual(response.payload, expectedResponse.payload)
    XCTAssertEqual(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReceivedArguments?.body as? KeyAttestationRequestBody, mockKeyAttestationRequestBody)
    XCTAssertEqual(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReceivedArguments?.audience, clientAttestationSigningDidMock)
    XCTAssertEqual(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReceivedArguments?.challengeEndpoint, URL(target: AttestationServiceEndpoint.challenge))
    XCTAssertEqual(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReceivedArguments?.clientAttestation, mockClientAttestation)
  }

  func testFetchKeyAttestation_generateProofOfPossessionFails_throwsError() async throws {
    proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderThrowableError = TestingError.error

    do {
      _ = try await repository.fetchKeyAttestation(body: mockKeyAttestationRequestBody, clientAttestation: mockClientAttestation)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testFetchKeyAttestation_failure() async throws {
    mockResponse(code: 500)

    do {
      _ = try await repository.fetchKeyAttestation(body: mockKeyAttestationRequestBody, clientAttestation: mockClientAttestation)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual((error as? NetworkError)?.status, .internalServerError)
    }
  }

  func testFetchKeyAttestation_timeout_throwsTimeout() async throws {
    mockResponse(code: 408)

    do {
      _ = try await repository.fetchKeyAttestation(
        body: mockKeyAttestationRequestBody,
        clientAttestation: mockClientAttestation)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? AppAttestationRepositoryError, .timeout)
    }
  }

  func testFetchKeyAttestation_teapot_throwsServiceDeactivated() async throws {
    mockResponse(code: 418)

    do {
      _ = try await repository.fetchKeyAttestation(
        body: mockKeyAttestationRequestBody,
        clientAttestation: mockClientAttestation)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? AppAttestationRepositoryError, .serviceDeactivated)
    }
  }

  func testFetchKeyAttestation_serviceUnavailable_throwsServiceDeactivated() async throws {
    mockResponse(code: 503)

    do {
      _ = try await repository.fetchKeyAttestation(
        body: mockKeyAttestationRequestBody,
        clientAttestation: mockClientAttestation)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? AppAttestationRepositoryError, .serviceDeactivated)
    }
  }

  // MARK: Private

  private let mockClientAttestation = ClientAttestationJWT.Mock.sample
  private let mockClientAttestationProofOfPossession = ClientAttestationProofOfPossession.Mock.sample
  private let mockClientAttestationRequestBody = ClientAttestationRequestBody.Mock.sample
  private let mockKeyAttestationRequestBody = KeyAttestationRequestBody.Mock.sample
  private let clientAttestationSigningDidMock = "did:tdw:example.com"
  private var repository: AppAttestationRepository!
  private var proofOfPossessionGenerator: ProofOfPossessionGeneratorProtocolSpy!
  private var didResolverSpy: DidResolverHelperProtocolSpy!

  private func mockResponse(code: Int, data: Data = Data()) {
    NetworkContainer.shared.endpointClosure.register {
      .networkResponse(code, data)
    }
  }

  private func createSuccessState() {
    proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReturnValue = mockClientAttestationProofOfPossession
    didResolverSpy.getDidFromReturnValue = clientAttestationSigningDidMock
  }

  private func registerMocks() {
    proofOfPossessionGenerator = ProofOfPossessionGeneratorProtocolSpy()
    didResolverSpy = DidResolverHelperProtocolSpy()

    Container.shared.proofOfPossessionGenerator.register { self.proofOfPossessionGenerator }
    Container.shared.didResolverHelper.register { self.didResolverSpy }
  }
}
