import Factory
import XCTest
@testable import BITAppAttestation
@testable import BITAppAuth
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITLocalAuthentication
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
    XCTAssertEqual(clientAttestationRepository.getUsingCallsCount, 1)
  }

  func testFetchRequestStatus_getClientAttestationFails_throwsError() async throws {
    clientAttestationRepository.getUsingThrowableError = TestingError.error

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
    XCTAssertEqual(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReceivedArguments?.body as? EIDRequestPayload, mockeIDRequestPayload)
    XCTAssertEqual(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReceivedArguments?.audience, strURL.absoluteString)
    XCTAssertEqual(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReceivedArguments?.challengeEndpoint, URL(target: EIDRequestEndpoint.challenge))
    XCTAssertEqual(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReceivedArguments?.clientAttestation, mockClientAttestation)
  }

  func testApplyRequest_generateProofOfPossessionsFails_throwsError() async throws {
    proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderThrowableError = TestingError.error

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
    XCTAssertEqual(clientAttestationRepository.getUsingCallsCount, 1)
  }

  func testFetchLegalRepresentantVerification_getClientAttestationFails_throwsError() async throws {
    clientAttestationRepository.getUsingThrowableError = TestingError.error

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

    XCTAssertEqual(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderCallsCount, 1)
  }

  func testStartOnlineSession_generateProofOfPossessionsFails_throwsError() async throws {
    proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderThrowableError = TestingError.error

    do {
      _ = try await repository.startOnlineSession(caseId: "caseId")
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertEqual(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderCallsCount, 1)
    }
  }

  // MARK: - Pair wallet

  func testPairWallet_success() async throws {
    mockResponse(code: 200, data: WalletPairingResponse.Mock.sampleData)

    let result = try await repository.pairWallet(caseId: "caseId")

    XCTAssertEqual(result, WalletPairingResponse.Mock.sample)
    XCTAssertEqual(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderCallsCount, 1)
  }

  func testPairWallet_generateProofOfPossessionsFails_throwsError() async throws {
    proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderThrowableError = TestingError.error

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
    XCTAssertEqual(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderCallsCount, 1)
  }

  func testPStartAutoVerification_generateProofOfPossessionsFails_throwsError() async throws {
    proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderThrowableError = TestingError.error

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

  // MARK: - Register push id

  func testRegisterPushId_success() async throws {
    let pushId = "pushId"
    mockResponse(code: 200)

    try await repository.registerPushId(mockePushIdRegistrationBody, caseId: "caseId")

    XCTAssertEqual(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderCallsCount, 1)
    XCTAssertEqual((proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReceivedArguments?.body as? PushIdRegistrationBody)?.pushId, pushId)
    XCTAssertEqual(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReceivedArguments?.audience, strURL.absoluteString)
    XCTAssertEqual(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReceivedArguments?.challengeEndpoint, URL(target: EIDRequestEndpoint.challenge))
    XCTAssertEqual(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReceivedArguments?.clientAttestation, mockClientAttestation)
  }

  func testRegisterPushId_getClientAttestationFails_throwsError() async throws {
    clientAttestationRepository.getUsingThrowableError = TestingError.error

    do {
      try await repository.registerPushId(mockePushIdRegistrationBody, caseId: "caseId")
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testRegisterPushId_generateProofOfPossessionsFails_throwsError() async throws {
    proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderThrowableError = TestingError.error

    do {
      try await repository.registerPushId(mockePushIdRegistrationBody, caseId: "caseId")
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let strURL = URL(string: "some://url")!
  private var repository = EIDRequestRepository()
  private let mockePushIdRegistrationBody = PushIdRegistrationBody.Mock.sample
  private let mockeIDRequestResponse: EIDRequestResponse = .Mock.sample
  private let mockValidateAttestationsRequestBody: ValidateAttestationsRequestBody = .Mock.sample

  private let mockClientAttestation = ClientAttestationJWT.Mock.sample
  private let mockClientAttestationProofOfPossession = ClientAttestationProofOfPossession.Mock.sample

  private var clientAttestationRepository: ClientAttestationRepositoryProtocolSpy!
  private var proofOfPossessionGenerator: ProofOfPossessionGeneratorProtocolSpy!
  private var userSession: SessionSpy!
  private var userContext: LAContextProtocolSpy!

  private func mockResponse(code: Int, data: Data = Data()) {
    NetworkContainer.shared.endpointClosure.register {
      .networkResponse(code, data)
    }
  }

  private func createSuccessState() {
    clientAttestationRepository.getUsingReturnValue = mockClientAttestation
    proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReturnValue = mockClientAttestationProofOfPossession
  }

  private func registerMocks() {
    clientAttestationRepository = ClientAttestationRepositoryProtocolSpy()
    proofOfPossessionGenerator = ProofOfPossessionGeneratorProtocolSpy()
    userSession = SessionSpy()
    userContext = LAContextProtocolSpy()
    userSession.isLoggedIn = true
    userSession.context = userContext

    Container.shared.clientAttestationRepository.register { self.clientAttestationRepository }
    Container.shared.proofOfPossessionGenerator.register { self.proofOfPossessionGenerator }
    Container.shared.userSession.register { self.userSession }
    Container.shared.sidBaseUrl.register { self.strURL }
  }

}

// swiftlint: enable implicitly_unwrapped_optional force_unwrapping
