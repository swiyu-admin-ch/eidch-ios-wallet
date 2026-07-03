import Factory
import Testing
@testable import BITEIDRequest
@testable import BITPushNotification
@testable import BITTestingCore

struct UpdatePushTokenUseCaseTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()

    let pushTokenRepository = PushTokenRepositoryProtocolSpy()
    pushTokenRepository.getCurrentReturnValue = mockPushToken
    self.pushTokenRepository = pushTokenRepository

    let pushNotificationRepository = PushNotificationRepositoryProtocolSpy()
    pushNotificationRepository.updateBodyReturnValue = .Mock.sample
    self.pushNotificationRepository = pushNotificationRepository

    let eIDRequestCaseRepository = EIDRequestCaseRepositoryProtocolSpy()
    eIDRequestCaseRepository.getAllPushIdsReturnValue = mockPushIds
    self.eIDRequestCaseRepository = eIDRequestCaseRepository

    Container.shared.pushTokenRepository.register { pushTokenRepository }
    Container.shared.pushNotificationRepository.register { pushNotificationRepository }
    Container.shared.eIDRequestCaseRepository.register { eIDRequestCaseRepository }

    useCase = UpdatePushTokenUseCase()
  }

  // MARK: Internal

  @Test
  func callAsFunction_success() async throws {
    try await useCase()

    #expect(pushTokenRepository.getCurrentCallsCount == 1)
    #expect(eIDRequestCaseRepository.getAllPushIdsCallsCount == 1)

    #expect(pushNotificationRepository.updateBodyCallsCount == 1)
    #expect(pushNotificationRepository.updateBodyReceivedBody?.pushIds == mockPushIds)
    #expect(pushNotificationRepository.updateBodyReceivedBody?.pushDeviceToken == mockPushToken)
  }

  @Test
  func callAsFunction_withoutPushToken_returns() async throws {
    pushTokenRepository.getCurrentReturnValue = nil

    try await useCase()

    #expect(pushTokenRepository.getCurrentCallsCount == 1)
    #expect(!eIDRequestCaseRepository.getAllPushIdsCalled)
    #expect(!pushNotificationRepository.updateBodyCalled)
  }

  @Test
  func callAsFunction_withoutPushIds_returns() async throws {
    eIDRequestCaseRepository.getAllPushIdsReturnValue = []

    try await useCase()

    #expect(pushTokenRepository.getCurrentCallsCount == 1)
    #expect(eIDRequestCaseRepository.getAllPushIdsCallsCount == 1)
    #expect(!pushNotificationRepository.updateBodyCalled)
  }

  @Test
  func callAsFunction_getAllPushIdsFails_throwsError() async {
    eIDRequestCaseRepository.getAllPushIdsThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await useCase()
    }

    #expect(pushTokenRepository.getCurrentCallsCount == 1)
    #expect(!pushNotificationRepository.updateBodyCalled)
  }

  @Test
  func callAsFunction_updateFails_throwsError() async {
    pushNotificationRepository.updateBodyThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await useCase()
    }
  }

  // MARK: Private

  private let mockPushToken = "push-token"
  private let mockPushIds = ["push-id-1", "push-id-2"]

  private let useCase: UpdatePushTokenUseCase

  private let pushTokenRepository: PushTokenRepositoryProtocolSpy
  private let eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocolSpy
  private let pushNotificationRepository: PushNotificationRepositoryProtocolSpy
}
