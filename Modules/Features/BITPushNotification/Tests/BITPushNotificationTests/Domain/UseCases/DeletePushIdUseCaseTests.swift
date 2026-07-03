import Factory
import Testing
@testable import BITPushNotification
@testable import BITTestingCore

struct DeletePushIdUseCaseTests {

  // MARK: Lifecycle

  init() {
    let pushNotificationRepository = PushNotificationRepositoryProtocolSpy()
    self.pushNotificationRepository = pushNotificationRepository

    Container.shared.pushNotificationRepository.register { pushNotificationRepository }

    useCase = DeletePushIdUseCase()
  }

  // MARK: Internal

  @Test
  func callAsFunction_success() async throws {
    try await useCase(mockPushId)

    #expect(pushNotificationRepository.deletePushIdCallsCount == 1)
    #expect(pushNotificationRepository.deletePushIdReceivedPushId == mockPushId)
  }

  @Test
  func callAsFunction_deleteFails_throwsError() async {
    pushNotificationRepository.deletePushIdThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await useCase(mockPushId)
    }
  }

  // MARK: Private

  private let mockPushId = "push_id"

  private let useCase: DeletePushIdUseCase
  private let pushNotificationRepository: PushNotificationRepositoryProtocolSpy
}
