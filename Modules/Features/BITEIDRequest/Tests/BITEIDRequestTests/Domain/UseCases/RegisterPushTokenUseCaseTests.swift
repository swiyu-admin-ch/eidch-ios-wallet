import Factory
import Testing
@testable import BITEIDRequest
@testable import BITPushNotification
@testable import BITTestingCore

struct RegisterPushTokenUseCaseTests {

  // MARK: Lifecycle

  init() {
    let pushTokenRepository = PushTokenRepositoryProtocolSpy()
    self.pushTokenRepository = pushTokenRepository

    let pushNotificationRepository = PushNotificationRepositoryProtocolSpy()
    pushNotificationRepository.registerBodyReturnValue = PushRegistrationResponse(pushId: mockPushId)
    self.pushNotificationRepository = pushNotificationRepository

    let eIDRequestCaseRepository = EIDRequestCaseRepositoryProtocolSpy()
    self.eIDRequestCaseRepository = eIDRequestCaseRepository

    let sidRepository = SIDRepositoryProtocolSpy()
    self.sidRepository = sidRepository

    Container.shared.pushTokenRepository.register { pushTokenRepository }
    Container.shared.pushNotificationRepository.register { pushNotificationRepository }
    Container.shared.eIDRequestCaseRepository.register { eIDRequestCaseRepository }
    Container.shared.sidRepository.register { sidRepository }

    useCase = RegisterPushTokenUseCase()
  }

  // MARK: Internal

  @Test
  func callAsFunction_withPushTokenAndCaseId_success() async throws {
    try await useCase(mockPushToken, caseId: caseId)

    checkDependenciesCalls()
  }

  @Test
  func callAsFunction_withCaseId_success() async throws {
    pushTokenRepository.getReturnValue = mockPushToken

    try await useCase(for: caseId)

    #expect(pushTokenRepository.getCallsCount == 1)
    checkDependenciesCalls()
  }

  @Test
  func callAsFunction_withoutPushToken_throwsError() async throws {
    pushTokenRepository.getThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await useCase(for: caseId)
    }
  }

  @Test
  func callAsFunction_registerPushNotificationFails_throwsError() async throws {
    pushNotificationRepository.registerBodyThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await useCase(mockPushToken, caseId: caseId)
    }
  }

  @Test
  func callAsFunction_registerPushIdFails_throwsError() async throws {
    sidRepository.registerPushIdCaseIdThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await useCase(mockPushToken, caseId: caseId)
    }
  }

  @Test
  func callAsFunction_savePushIdFails_throwsError() async throws {
    eIDRequestCaseRepository.savePushIdForThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await useCase(mockPushToken, caseId: caseId)
    }
  }

  // MARK: Private

  private let caseId = "case-id"
  private let mockPushId = "mock_push_id"
  private let mockPushToken = "mock_push_token"
  private let platform = "ios"

  private let useCase: RegisterPushTokenUseCase

  private let pushTokenRepository: PushTokenRepositoryProtocolSpy
  private let sidRepository: SIDRepositoryProtocolSpy
  private let eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocolSpy
  private let pushNotificationRepository: PushNotificationRepositoryProtocolSpy

  private func checkDependenciesCalls() {
    #expect(pushNotificationRepository.registerBodyCallsCount == 1)
    #expect(pushNotificationRepository.registerBodyReceivedBody?.platform == platform)
    #expect(pushNotificationRepository.registerBodyReceivedBody?.pushDeviceToken == mockPushToken)

    #expect(sidRepository.registerPushIdCaseIdCallsCount == 1)
    #expect(sidRepository.registerPushIdCaseIdReceivedArguments?.caseId == caseId)
    #expect(sidRepository.registerPushIdCaseIdReceivedArguments?.body.pushId == mockPushId)

    #expect(eIDRequestCaseRepository.savePushIdForCallsCount == 1)
    #expect(eIDRequestCaseRepository.savePushIdForReceivedArguments?.pushId == mockPushId)
    #expect(eIDRequestCaseRepository.savePushIdForReceivedArguments?.caseId == caseId)
  }
}
