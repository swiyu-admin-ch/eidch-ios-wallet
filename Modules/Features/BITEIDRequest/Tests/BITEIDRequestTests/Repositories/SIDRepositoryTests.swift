import Factory
import FactoryTesting
import Foundation
import Testing
@testable import BITAppAttestation
@testable import BITAppAuth
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITLocalAuthentication
@testable import BITNetworking
@testable import BITTestingCore

@Suite(.container)
struct SIDRepositoryTests {

  // MARK: Lifecycle

  init() throws {
    let clientAttestationRepository = ClientAttestationRepositoryProtocolSpy()
    clientAttestationRepository.getUsingReturnValue = mockClientAttestation
    self.clientAttestationRepository = clientAttestationRepository

    let proofOfPossessionGenerator = ProofOfPossessionGeneratorProtocolSpy()
    proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReturnValue = mockClientAttestationProofOfPossession
    self.proofOfPossessionGenerator = proofOfPossessionGenerator

    let userSession = SessionSpy()
    let userContext = LAContextProtocolSpy()
    userSession.isLoggedIn = true
    userSession.context = userContext

    self.userContext = userContext
    self.userSession = userSession

    let strURL = try #require(URL(string: "some://url"))
    self.strURL = strURL

    Container.shared.clientAttestationRepository.register { clientAttestationRepository }
    Container.shared.proofOfPossessionGenerator.register { proofOfPossessionGenerator }
    Container.shared.userSession.register { userSession }
    Container.shared.sidBaseUrl.register { strURL }

    NetworkContainer.shared.stubClosure.register {
      { _ in .immediate }
    }

    repository = SIDRepository()
  }

  // MARK: Internal

  // MARK: - Fetch status

  @Test
  func fetchRequestStatus_success() async throws {
    let expectedStatus = EIDRequestStatus.Mock.inQueueSample
    mockResponse(code: 200, data: EIDRequestStatus.Mock.sampleData)

    let status = try await repository.fetchRequestStatus(for: mockeIDRequestResponse.caseId)

    #expect(expectedStatus == status)
    #expect(clientAttestationRepository.getUsingCallsCount == 1)
  }

  @Test
  func fetchRequestStatus_getClientAttestationFails_throwsError() async throws {
    clientAttestationRepository.getUsingThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      _ = try await repository.fetchRequestStatus(for: mockeIDRequestResponse.caseId)
    }
  }

  // MARK: - Apply request

  @Test
  func applyRequest_success() async throws {
    let expectedResponse = EIDRequestResponse.Mock.sample

    let mockeIDRequestPayload = try #require(MRZData.Mock.array.first?.payload)

    mockResponse(code: 200, data: EIDRequestResponse.Mock.sampleData)

    let response = try await repository.apply(with: mockeIDRequestPayload)

    #expect(expectedResponse == response)
    #expect(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReceivedArguments?.body as? EIDRequestPayload == mockeIDRequestPayload)
    #expect(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReceivedArguments?.audience == strURL.absoluteString)
    #expect(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReceivedArguments?.challengeEndpoint == URL(target: SIDRepositoryEndpoint.challenge))
    #expect(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReceivedArguments?.clientAttestation == mockClientAttestation)
  }

  @Test
  func applyRequest_generateProofOfPossessionsFails_throwsError() async throws {
    proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderThrowableError = TestingError.error

    let mockeIDRequestPayload = try #require(MRZData.Mock.array.first?.payload)

    await #expect(throws: TestingError.error) {
      _ = try await repository.apply(with: mockeIDRequestPayload)
    }
  }

  // MARK: - Fetch legal representant verification

  @Test
  func fetchLegalRepresentantVerification_success() async throws {
    let expected = LegalRepresentantVerificationResponse.Mock.sample
    mockResponse(code: 200, data: LegalRepresentantVerificationResponse.Mock.sampleData)

    let response = try await repository.fetchLegalRepresentantVerification(for: mockCaseId)

    #expect(expected == response)
    #expect(clientAttestationRepository.getUsingCallsCount == 1)
  }

  @Test
  func fetchLegalRepresentantVerification_getClientAttestationFails_throwsError() async throws {
    clientAttestationRepository.getUsingThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      _ = try await repository.fetchLegalRepresentantVerification(for: mockCaseId)
    }
  }

  @Test
  func fetchLegalRepresentantVerification_legalRepresentantNotRequired_throwsLegalRepresentantNotRequiredError() async throws {
    try mockResponse(code: 400, data: JSONEncoder().encode(EIDRequestErrorResponse.Mock.legalRepresentantNotRequiredSample))

    await #expect(throws: SIDRepository.Error.legalRepresentantNotRequired) {
      _ = try await repository.fetchLegalRepresentantVerification(for: mockCaseId)
    }
  }

  // MARK: - Validate attestations

  @Test
  func validateAttestations_clientAttestationInvalid_throwsInvalidClientAttestationError() async throws {
    try mockResponse(code: 422, data: JSONEncoder().encode(EIDRequestErrorResponse.Mock.clientAttestationSample))

    await #expect(throws: SIDRepository.Error.invalidClientAttestation) {
      try await repository.validateAttestations(mockValidateAttestationsRequestBody)
    }
  }

  @Test
  func validateAttestations_keyAttestationInvalid_throwsInvalidKeyAttestationError() async throws {
    try mockResponse(code: 422, data: JSONEncoder().encode(EIDRequestErrorResponse.Mock.keyAttestationSample))

    await #expect(throws: SIDRepository.Error.invalidKeyAttestation) {
      try await repository.validateAttestations(mockValidateAttestationsRequestBody)
    }
  }

  @Test
  func validateAttestations_insufficientKeyStorageResistance_throwsInsufficientKeyStorageResistanceError() async throws {
    try mockResponse(code: 422, data: JSONEncoder().encode(EIDRequestErrorResponse.Mock.insuffisanceResistanceSample))

    await #expect(throws: SIDRepository.Error.insufficientKeyStorageResistance) {
      try await repository.validateAttestations(mockValidateAttestationsRequestBody)
    }
  }

  @Test
  func validateAttestationsFails_throwsUnknownError() async throws {
    mockResponse(code: 400)

    await #expect(throws: SIDRepository.Error.unknownError) {
      try await repository.validateAttestations(mockValidateAttestationsRequestBody)
    }
  }

  // MARK: - Start online session

  @Test
  func startOnlineSession_success() async throws {
    mockResponse(code: 200)

    try await repository.startOnlineSession(caseId: mockCaseId)

    #expect(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderCallsCount == 1)
  }

  @Test
  func startOnlineSession_generateProofOfPossessionsFails_throwsError() async throws {
    proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await repository.startOnlineSession(caseId: mockCaseId)
    }
    #expect(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderCallsCount == 1)
  }

  // MARK: - Pair wallet

  @Test
  func pairWallet_success() async throws {
    mockResponse(code: 200, data: WalletPairingResponse.Mock.sampleData)

    let result = try await repository.pairWallet(caseId: mockCaseId)

    #expect(result == WalletPairingResponse.Mock.sample)
    #expect(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderCallsCount == 1)
  }

  @Test
  func pairWallet_generateProofOfPossessionsFails_throwsError() async throws {
    proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      _ = try await repository.pairWallet(caseId: mockCaseId)
    }
  }

  // MARK: - Start auto verification

  @Test
  func startAutoVerification_success() async throws {
    mockResponse(code: 200, data: AutoVerificationResponse.Mock.sampleData)

    let result = try await repository.startAutoVerification(caseId: mockCaseId, autoVerificationType: .av1, isNFCAvailable: true)

    #expect(result == AutoVerificationResponse.Mock.nfcSample)
    #expect(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderCallsCount == 1)
  }

  @Test
  func startAutoVerification_generateProofOfPossessionsFails_throwsError() async throws {
    proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      _ = try await repository.startAutoVerification(caseId: mockCaseId, autoVerificationType: .av1, isNFCAvailable: true)
    }
  }

  // MARK: - Register push id

  @Test
  func registerPushId_success() async throws {
    let pushId = "pushId"
    mockResponse(code: 200)

    try await repository.registerPushId(mockePushIdRegistrationBody, caseId: mockCaseId)

    #expect(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderCallsCount == 1)
    #expect((proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReceivedArguments?.body as? PushIdRegistrationBody)?.pushId == pushId)
    #expect(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReceivedArguments?.audience == strURL.absoluteString)
    #expect(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReceivedArguments?.challengeEndpoint == URL(target: SIDRepositoryEndpoint.challenge))
    #expect(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReceivedArguments?.clientAttestation == mockClientAttestation)
  }

  @Test
  func registerPushId_getClientAttestationFails_throwsError() async throws {
    clientAttestationRepository.getUsingThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await repository.registerPushId(mockePushIdRegistrationBody, caseId: mockCaseId)
    }
  }

  @Test
  func registerPushId_generateProofOfPossessionsFails_throwsError() async throws {
    proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await repository.registerPushId(mockePushIdRegistrationBody, caseId: mockCaseId)
    }
  }

  // MARK: - Abort request case

  @Test
  func abortRequestCase_success() async throws {
    mockResponse(code: 200)

    try await repository.abortRequestCase(for: mockCaseId)

    #expect(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderCallsCount == 1)
  }

  @Test
  func abortRequestCase_generateProofOfPossessionsFails_throwsError() async throws {
    proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await repository.abortRequestCase(for: mockCaseId)
    }
  }

  // MARK: Private

  private let strURL: URL
  private let repository: SIDRepository
  private let mockCaseId = "caseId"
  private let mockePushIdRegistrationBody = PushIdRegistrationBody.Mock.sample
  private let mockeIDRequestResponse: EIDRequestResponse = .Mock.sample
  private let mockValidateAttestationsRequestBody: ValidateAttestationsRequestBody = .Mock.sample

  private let mockClientAttestation = ClientAttestationJWT.Mock.sample
  private let mockClientAttestationProofOfPossession = ClientAttestationProofOfPossession.Mock.sample

  private let clientAttestationRepository: ClientAttestationRepositoryProtocolSpy
  private let proofOfPossessionGenerator: ProofOfPossessionGeneratorProtocolSpy
  private let userSession: SessionSpy
  private let userContext: LAContextProtocolSpy

  private func mockResponse(code: Int, data: Data = Data()) {
    NetworkContainer.shared.endpointClosure.register {
      .networkResponse(code, data)
    }
  }

}
