import Factory
import Testing
@testable import BITPushNotification

struct ResetApplicationBadgeUseCaseTests {

  // MARK: Lifecycle

  init() {
    let pushNotificationCenterRepository = PushNotificationCenterRepositoryProtocolSpy()
    self.pushNotificationCenterRepository = pushNotificationCenterRepository

    Container.shared.pushNotificationCenterRepository.register { pushNotificationCenterRepository }

    useCase = ResetApplicationBadgeUseCase()
  }

  // MARK: Internal

  @Test
  func resetApplicationBadge_setsBadgeCountToZero() async throws {
    try await useCase()

    #expect(pushNotificationCenterRepository.setBadgeCountCallsCount == 1)
    #expect(pushNotificationCenterRepository.setBadgeCountReceivedCount == 0)
  }

  // MARK: Private

  private let useCase: ResetApplicationBadgeUseCase
  private let pushNotificationCenterRepository: PushNotificationCenterRepositoryProtocolSpy
}
