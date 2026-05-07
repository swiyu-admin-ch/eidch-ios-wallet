import Factory
import XCTest
@testable import BITAppAttestation
@testable import BITAppAuth
@testable import BITLocalAuthentication
@testable import BITNetworking
@testable import BITOTP
@testable import BITTestingCore

// swiftlint: disable implicitly_unwrapped_optional force_unwrapping

final class OTPRequestRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    registerMocks()
    repository = OTPRequestRepository()
    createSuccessState()

    NetworkContainer.shared.reset()
    NetworkContainer.shared.stubClosure.register {
      { _ in .immediate }
    }
  }

  override func tearDown() {
    NetworkContainer.shared.reset()
    super.tearDown()
  }

  func testRequestOTP_success() async throws {
    mockResponse(code: 200)

    try await repository.requestOTP(email: "user@example.admin.ch")

    XCTAssertEqual(clientAttestationRepository.getUsingCallsCount, 1)
    XCTAssertEqual(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationCallsCount, 1)
    XCTAssertEqual(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationReceivedArguments?.audience, otpServiceBaseUrl.absoluteString)
    XCTAssertEqual(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationReceivedArguments?.challengeEndpoint, attestationServiceUrl.appendingPathComponent("challenge"))
  }

  func testRequestOTP_sessionMissing_throwsInvalidClientAttestation() async {
    userSession.isLoggedIn = false
    userSession.context = nil

    await assertThrowsOTPError(
      expectedError: .invalidClientAttestation,
      action: { try await self.repository.requestOTP(email: "user@example.admin.ch") })

    XCTAssertEqual(clientAttestationRepository.getUsingCallsCount, 0)
  }

  func testRequestOTP_clientAttestationFails_throwsInvalidClientAttestation() async {
    clientAttestationRepository.getUsingThrowableError = TestingError.error

    await assertThrowsOTPError(
      expectedError: .invalidClientAttestation,
      action: { try await self.repository.requestOTP(email: "user@example.admin.ch") })
  }

  func testRequestOTP_generateProofOfPossessionFails_throwsInvalidClientAttestation() async {
    proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationThrowableError = TestingError.error

    await assertThrowsOTPError(
      expectedError: .invalidClientAttestation,
      action: { try await self.repository.requestOTP(email: "user@example.admin.ch") })
  }

  func testRequestOTP_forbidden_throwsForbiddenEmail() async {
    mockResponse(code: 403)

    await assertThrowsOTPError(
      expectedError: .forbiddenEmail,
      action: { try await self.repository.requestOTP(email: "user@example.admin.ch") })
  }

  func testRequestOTP_badRequest_throwsInvalidFormat() async {
    mockResponse(code: 400)

    await assertThrowsOTPError(
      expectedError: .invalidFormat,
      action: { try await self.repository.requestOTP(email: "user@example.admin.ch") })
  }

  func testRequestOTP_serviceDeactivated_throwsServiceDeactivated() async {
    mockResponse(code: 418)

    await assertThrowsOTPError(
      expectedError: .serviceDeactivated,
      action: { try await self.repository.requestOTP(email: "user@example.admin.ch") })
  }

  func testRequestOTP_internalServerError_throwsUnknown() async {
    mockResponse(code: 500)

    await assertThrowsOTPError(
      expectedError: .unknown,
      action: { try await self.repository.requestOTP(email: "user@example.admin.ch") })
  }

  func testVerifyOTP_success() async throws {
    mockResponse(code: 200)

    try await repository.verifyOTP(email: "user@example.admin.ch", code: "123456")

    XCTAssertEqual(clientAttestationRepository.getUsingCallsCount, 1)
    XCTAssertEqual(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationCallsCount, 1)
    XCTAssertEqual(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationReceivedArguments?.audience, otpServiceBaseUrl.absoluteString)
    XCTAssertEqual(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationReceivedArguments?.challengeEndpoint, attestationServiceUrl.appendingPathComponent("challenge"))
  }

  func testVerifyOTP_generateProofOfPossessionFails_throwsInvalidClientAttestation() async {
    proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationThrowableError = TestingError.error

    await assertThrowsOTPError(
      expectedError: .invalidClientAttestation,
      action: { try await self.repository.verifyOTP(email: "user@example.admin.ch", code: "123456") })
  }

  func testVerifyOTP_unauthorized_throwsInvalidClientAttestation() async {
    mockResponse(code: 401)

    await assertThrowsOTPError(
      expectedError: .invalidClientAttestation,
      action: { try await self.repository.verifyOTP(email: "user@example.admin.ch", code: "123456") })
  }

  func testVerifyOTP_gone_throwsOTPExpired() async {
    mockResponse(code: 410)

    await assertThrowsOTPError(
      expectedError: .otpExpired,
      action: { try await self.repository.verifyOTP(email: "user@example.admin.ch", code: "123456") })
  }

  func testVerifyOTP_forbidden_throwsInvalidFormat() async {
    mockResponse(code: 403)

    await assertThrowsOTPError(
      expectedError: .invalidFormat,
      action: { try await self.repository.verifyOTP(email: "user@example.admin.ch", code: "123456") })
  }

  func testVerifyOTP_badRequest_throwsUnknown() async {
    mockResponse(code: 400)

    await assertThrowsOTPError(
      expectedError: .unknown,
      action: { try await self.repository.verifyOTP(email: "user@example.admin.ch", code: "123456") })
  }

  func testVerifyOTP_tooManyRequests_throwsTooManyRequests() async {
    mockResponse(code: 429)

    await assertThrowsOTPError(
      expectedError: .tooManyRequests,
      action: { try await self.repository.verifyOTP(email: "user@example.admin.ch", code: "123456") })
  }

  func testVerifyOTP_serviceDeactivated_throwsServiceDeactivated() async {
    mockResponse(code: 418)

    await assertThrowsOTPError(
      expectedError: .serviceDeactivated,
      action: { try await self.repository.verifyOTP(email: "user@example.admin.ch", code: "123456") })
  }

  func testVerifyOTP_internalServerError_throwsUnknown() async {
    mockResponse(code: 500)

    await assertThrowsOTPError(
      expectedError: .unknown,
      action: { try await self.repository.verifyOTP(email: "user@example.admin.ch", code: "123456") })
  }

  // MARK: Private

  private let otpServiceBaseUrl = URL(string: "https://otp.example.admin.ch/api")!
  private let attestationServiceUrl = URL(string: "https://attestation.example.admin.ch/api/attestations")!

  private var repository: OTPRequestRepository!
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
    clientAttestationRepository.getUsingReturnValue = ClientAttestationJWT.Mock.sample
    proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationReturnValue = ClientAttestationProofOfPossession.Mock.sample
  }

  private func registerMocks() {
    clientAttestationRepository = ClientAttestationRepositoryProtocolSpy()
    proofOfPossessionGenerator = ProofOfPossessionGeneratorProtocolSpy()
    userSession = SessionSpy()
    userContext = LAContextProtocolSpy()
    userSession.isLoggedIn = true
    userSession.context = userContext

    Container.shared.otpServiceBaseUrl.register { self.otpServiceBaseUrl }
    Container.shared.attestationServiceUrl.register { self.attestationServiceUrl }
    Container.shared.clientAttestationRepository.register { self.clientAttestationRepository }
    Container.shared.proofOfPossessionGenerator.register { self.proofOfPossessionGenerator }
    Container.shared.userSession.register { self.userSession }
  }

  private func assertThrowsOTPError(
    expectedError: OTPError,
    action: () async throws -> Void)
    async
  {
    do {
      try await action()
      XCTFail("Expected \(expectedError)")
    } catch let error as OTPError {
      XCTAssertEqual(error, expectedError)
    } catch {
      XCTFail("Expected OTPError.\(expectedError), got \(type(of: error))")
    }
  }
}

// swiftlint: enable implicitly_unwrapped_optional force_unwrapping
