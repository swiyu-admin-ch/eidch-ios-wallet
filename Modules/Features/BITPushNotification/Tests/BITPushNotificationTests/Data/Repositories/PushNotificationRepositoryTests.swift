import Factory
import Foundation
import Testing
@testable import BITAppAttestation
@testable import BITAppAuth
@testable import BITLocalAuthentication
@testable import BITNetworking
@testable import BITPushNotification
@testable import BITTestingCore

struct PushNotificationRepositoryTests {

  // MARK: Lifecycle

  init() {
    NetworkContainer.shared.stubClosure.register {
      { _ in .immediate }
    }

    let clientAttestationRepository = ClientAttestationRepositoryProtocolSpy()
    clientAttestationRepository.getUsingReturnValue = ClientAttestationJWT.Mock.sample
    self.clientAttestationRepository = clientAttestationRepository

    let proofOfPossessionGenerator = ProofOfPossessionGeneratorProtocolSpy()
    proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReturnValue = ClientAttestationProofOfPossession.Mock.sample
    self.proofOfPossessionGenerator = proofOfPossessionGenerator

    let userSession = SessionSpy()
    let userContext = LAContextProtocolSpy()
    userSession.isLoggedIn = true
    userSession.context = userContext

    self.userContext = userContext
    self.userSession = userSession

    Container.shared.clientAttestationRepository.register { clientAttestationRepository }
    Container.shared.proofOfPossessionGenerator.register { proofOfPossessionGenerator }
    Container.shared.userSession.register { userSession }

    repository = PushNotificationRepository()
  }

  // MARK: Internal

  // MARK: - Register

  @Test
  func register_success() async throws {
    mockResponse(code: 200, data: PushRegistrationResponse.Mock.sampleData)

    let result = try await repository.register(body: mockRegistrationBody)

    #expect(result == PushRegistrationResponse.Mock.sample)

    #expect(clientAttestationRepository.getUsingCallsCount == 1)

    #expect(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderCallsCount == 1)
    #expect(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReceivedArguments?.body as? PushRegistrationBody == mockRegistrationBody)
  }

  @Test
  func register_userIsNotLoggedIn_throwsError() async {
    userSession.isLoggedIn = false

    await #expect(throws: PushNotificationRepositoryError.invalidSession) {
      try await repository.register(body: mockRegistrationBody)
    }
  }

  @Test
  func register_clientAttestationFetchFails_throwsError() async throws {
    clientAttestationRepository.getUsingThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await repository.register(body: mockRegistrationBody)
    }
  }

  @Test
  func register_proofOfPossessionGenerationFails_throwsError() async throws {
    proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await repository.register(body: mockRegistrationBody)
    }
  }

  // MARK: - Update

  @Test
  func update_success() async throws {
    mockResponse(code: 200, data: PushUpdateResponse.Mock.sampleData)

    let result = try await repository.update(body: mockUpdateBody)

    #expect(clientAttestationRepository.getUsingCallsCount == 1)
    #expect(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderCallsCount == 1)
    #expect(result == PushUpdateResponse.Mock.sample)

    let body = try #require(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderReceivedArguments?.body as? PushUpdateBody)
    #expect(body == mockUpdateBody)
  }

  @Test
  func update_userIsNotLoggedIn_throwsError() async {
    userSession.isLoggedIn = false

    await #expect(throws: PushNotificationRepositoryError.invalidSession) {
      try await repository.update(body: mockUpdateBody)
    }
  }

  @Test
  func update_clientAttestationFetchFails_throwsError() async throws {
    clientAttestationRepository.getUsingThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await repository.update(body: mockUpdateBody)
    }
  }

  @Test
  func update_proofOfPossessionGenerationFails_throwsError() async throws {
    proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await repository.update(body: mockUpdateBody)
    }
  }

  // MARK: - Delete

  @Test
  func delete_success() async throws {
    mockResponse(code: 204)

    try await repository.delete(pushId: mockPushId)

    #expect(clientAttestationRepository.getUsingCallsCount == 1)
    #expect(proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderCallsCount == 1)
  }

  @Test
  func delete_userIsNotLoggedIn_throwsError() async {
    userSession.isLoggedIn = false

    await #expect(throws: PushNotificationRepositoryError.invalidSession) {
      try await repository.delete(pushId: mockPushId)
    }
  }

  @Test
  func delete_clientAttestationFetchFails_throwsError() async throws {
    clientAttestationRepository.getUsingThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await repository.delete(pushId: mockPushId)
    }
  }

  @Test
  func delete_proofOfPossessionGenerationFails_throwsError() async throws {
    proofOfPossessionGenerator.callAsFunctionForAudienceChallengeEndpointClientAttestationEncoderThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await repository.delete(pushId: mockPushId)
    }
  }

  // MARK: Private

  private let mockRegistrationBody = PushRegistrationBody.Mock.sample
  private let mockPushId = "push_id"
  private let mockUpdateBody = PushUpdateBody.Mock.sample
  private let repository: PushNotificationRepository

  private let userSession: SessionSpy
  private let userContext: LAContextProtocolSpy
  private let clientAttestationRepository: ClientAttestationRepositoryProtocolSpy
  private let proofOfPossessionGenerator: ProofOfPossessionGeneratorProtocolSpy

  private func mockResponse(code: Int, data: Data = Data()) {
    NetworkContainer.shared.endpointClosure.register {
      .networkResponse(code, data)
    }
  }
}
