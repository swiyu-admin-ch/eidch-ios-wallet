import Factory
import XCTest
@testable import BITAppAttestation
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITNetworking
@testable import BITTestingCore

// swiftlint: disable implicitly_unwrapped_optional force_unwrapping

// MARK: - OpenIDCredentialRepository

final class EIDRequestRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    registerMocks()
    repository = EIDRequestRepository()
    createSuccessState()

    NetworkContainer.shared.reset()
    NetworkContainer.shared.stubClosure.register {
      { _ in .immediate }
    }
  }

  // MARK: - Fetch status

  func testFetchRequestStatus_success() async throws {
    let expectedStatus = EIDRequestStatus.Mock.inQueueSample
    mockResponse(code: 200, data: EIDRequestStatus.Mock.sampleData)

    let status = try await repository.fetchRequestStatus(for: mockeIDRequestResponse.caseId)

    XCTAssertEqual(expectedStatus, status)
    XCTAssertEqual(clientAttestationRepository.getCallsCount, 1)
  }

  func testFetchRequestStatus_getClientAttestationFails_throwsError() async throws {
    clientAttestationRepository.getThrowableError = TestingError.error

    do {
      _ = try await repository.fetchRequestStatus(for: mockeIDRequestResponse.caseId)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: - Apply request

  func testApplyRequest_success() async throws {
    let expectedResponse = EIDRequestResponse.Mock.sample

    guard let mockeIDRequestPayload: EIDRequestPayload = MRZData.Mock.array.first?.payload else {
      fatalError("Failed to create mock EIDRequestPayload")
    }

    mockResponse(code: 200, data: EIDRequestResponse.Mock.sampleData)

    let response = try await repository.apply(with: mockeIDRequestPayload)

    XCTAssertEqual(expectedResponse, response)
    XCTAssertEqual(proofOfPossessionGenerator.generateForAudienceChallengeEndpointReceivedArguments?.body as? EIDRequestPayload, mockeIDRequestPayload)
    XCTAssertEqual(proofOfPossessionGenerator.generateForAudienceChallengeEndpointReceivedArguments?.audience, strURL.absoluteString)
    XCTAssertEqual(proofOfPossessionGenerator.generateForAudienceChallengeEndpointReceivedArguments?.challengeEndpoint, URL(target: EIDRequestEndpoint.challenge))
  }

  func testApplyRequest_generateProofOfPossessionsFails_throwsError() async throws {
    proofOfPossessionGenerator.generateForAudienceChallengeEndpointThrowableError = TestingError.error

    guard let mockeIDRequestPayload: EIDRequestPayload = MRZData.Mock.array.first?.payload else {
      fatalError("Failed to create mock EIDRequestPayload")
    }

    do {
      _ = try await repository.apply(with: mockeIDRequestPayload)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: - Fetch legal representant verification

  func testFetchLegalRepresentantVerification_success() async throws {
    let expected = LegalRepresentantVerificationResponse.Mock.sample
    mockResponse(code: 200, data: LegalRepresentantVerificationResponse.Mock.sampleData)

    let response = try await repository.fetchLegalRepresentantVerification(for: "caseId")

    XCTAssertEqual(expected, response)
    XCTAssertEqual(clientAttestationRepository.getCallsCount, 1)
  }

  func testFetchLegalRepresentantVerification_getClientAttestationFails_throwsError() async throws {
    clientAttestationRepository.getThrowableError = TestingError.error

    do {
      _ = try await repository.fetchLegalRepresentantVerification(for: "caseId")
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testFetchLegalRepresentantVerification_legalRepresentantNotRequired_throwsLegalRepresentantNotRequiredError() async throws {
    try mockResponse(code: 400, data: JSONEncoder().encode(EIDRequestErrorResponse.Mock.legalRepresentantNotRequiredSample))

    do {
      _ = try await repository.fetchLegalRepresentantVerification(for: "caseId")
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? EIDRequestRepository.Error, .legalRepresentantNotRequired)
    }
  }

  // MARK: - Validate attestations

  func testValidateAttestations_clientAttestationInvalid_throwsInvalidClientAttestationError() async throws {
    try mockResponse(code: 422, data: JSONEncoder().encode(EIDRequestErrorResponse.Mock.clientAttestationSample))

    do {
      try await repository.validateAttestations(mockValidateAttestationsRequestBody)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? EIDRequestRepository.Error, .invalidClientAttestation)
    }
  }

  func testValidateAttestations_keyAttestationInvalid_throwsInvalidKeyAttestationError() async throws {
    try mockResponse(code: 422, data: JSONEncoder().encode(EIDRequestErrorResponse.Mock.keyAttestationSample))

    do {
      try await repository.validateAttestations(mockValidateAttestationsRequestBody)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? EIDRequestRepository.Error, .invalidKeyAttestation)
    }
  }

  func testValidateAttestations_insufficientKeyStorageResistance_throwsInsufficientKeyStorageResistanceError() async throws {
    try mockResponse(code: 422, data: JSONEncoder().encode(EIDRequestErrorResponse.Mock.insuffisanceResistanceSample))

    do {
      try await repository.validateAttestations(mockValidateAttestationsRequestBody)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? EIDRequestRepository.Error, .insufficientKeyStorageResistance)
    }
  }

  func testValidateAttestationsFails_throwsUnknownError() async throws {
    mockResponse(code: 400)

    do {
      try await repository.validateAttestations(mockValidateAttestationsRequestBody)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? EIDRequestRepository.Error, .unknownError)
    }
  }

  // MARK: - Start online session

  func testStartOnlineSession_success() async throws {
    mockResponse(code: 200)

    try await repository.startOnlineSession(caseId: "caseId")

    XCTAssertEqual(proofOfPossessionGenerator.generateForAudienceChallengeEndpointCallsCount, 1)
  }

  func testStartOnlineSession_generateProofOfPossessionsFails_throwsError() async throws {
    proofOfPossessionGenerator.generateForAudienceChallengeEndpointThrowableError = TestingError.error

    do {
      _ = try await repository.startOnlineSession(caseId: "caseId")
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertEqual(proofOfPossessionGenerator.generateForAudienceChallengeEndpointCallsCount, 1)
    }
  }

  // MARK: - Pair wallet

  func testPairWallet_success() async throws {
    mockResponse(code: 200, data: WalletPairingResponse.Mock.sampleData)

    let result = try await repository.pairWallet(caseId: "caseId")

    XCTAssertEqual(result, WalletPairingResponse.Mock.sample)
    XCTAssertEqual(proofOfPossessionGenerator.generateForAudienceChallengeEndpointCallsCount, 1)
  }

  func testPairWallet_generateProofOfPossessionsFails_throwsError() async throws {
    proofOfPossessionGenerator.generateForAudienceChallengeEndpointThrowableError = TestingError.error

    do {
      _ = try await repository.pairWallet(caseId: "caseId")
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: - Start auto verification

  func testStartAutoVerification_success() async throws {
    mockResponse(code: 200, data: AutoVerificationResponse.Mock.sampleData)

    let result = try await repository.startAutoVerification(caseId: "caseId", autoVerificationType: .av1, isNFCAvailable: true)

    XCTAssertEqual(result, AutoVerificationResponse.Mock.nfcSample)
    XCTAssertEqual(proofOfPossessionGenerator.generateForAudienceChallengeEndpointCallsCount, 1)
  }

  func testPStartAutoVerification_generateProofOfPossessionsFails_throwsError() async throws {
    proofOfPossessionGenerator.generateForAudienceChallengeEndpointThrowableError = TestingError.error

    do {
      _ = try await repository.startAutoVerification(caseId: "caseId", autoVerificationType: .av1, isNFCAvailable: true)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }


  func testSubmitRequest_success() async throws {
    mockResponse(code: 200)

    try await repository.submitRequest(caseId: "caseId", authJwt: "authJwt")
  }

  func testSubmitRequest_throwsError() async throws {
    mockResponse(code: 404)

    do {
      try await repository.submitRequest(caseId: "caseId", authJwt: "authJwt")
      XCTFail("Expected an error")
    } catch {
      XCTAssert(error is NetworkError)
    }
  }

  // MARK: Private

  private let strURL = URL(string: "some://url")!
  private var repository = EIDRequestRepository()
  private let mockeIDRequestResponse: EIDRequestResponse = .Mock.sample
  private let mockValidateAttestationsRequestBody: ValidateAttestationsRequestBody = .Mock.sample

  private let mockClientAttestation = ClientAttestationJWT.Mock.sample
  private let mockClientAttestationProofOfPossession = ClientAttestationProofOfPossession.Mock.sample

  private var clientAttestationRepository: ClientAttestationRepositoryProtocolSpy!
  private var proofOfPossessionGenerator: ProofOfPossessionGeneratorProtocolSpy!

  private func mockResponse(code: Int, data: Data = Data()) {
    NetworkContainer.shared.endpointClosure.register {
      .networkResponse(code, data)
    }
  }

  private func createSuccessState() {
    clientAttestationRepository.getReturnValue = mockClientAttestation
    proofOfPossessionGenerator.generateForAudienceChallengeEndpointReturnValue = (mockClientAttestation, mockClientAttestationProofOfPossession)
  }

  private func registerMocks() {
    clientAttestationRepository = ClientAttestationRepositoryProtocolSpy()
    proofOfPossessionGenerator = ProofOfPossessionGeneratorProtocolSpy()

    Container.shared.clientAttestationRepository.register { self.clientAttestationRepository }
    Container.shared.proofOfPossessionGenerator.register { self.proofOfPossessionGenerator }
    Container.shared.sidBaseUrl.register { self.strURL }
  }

}

// swiftlint: enable implicitly_unwrapped_optional force_unwrapping
