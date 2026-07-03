import Factory
import Testing
import UserNotifications
@testable import BITPushNotification

struct GetPushPermissionStatusUseCaseTests {

  // MARK: Lifecycle

  init() {
    let pushNotificationCenterRepository = PushNotificationCenterRepositoryProtocolSpy()
    self.pushNotificationCenterRepository = pushNotificationCenterRepository

    Container.shared.pushNotificationCenterRepository.register { pushNotificationCenterRepository }

    useCase = GetPushPermissionStatusUseCase()
  }

  // MARK: Internal

  @Test
  func getStatus_returnsAuthorizationStatus() async {
    pushNotificationCenterRepository.notificationSettingsReturnValue = UNNotificationSettingsMock(authorizationStatus: .authorized)

    let status = await useCase()

    #expect(status == .authorized)
    #expect(pushNotificationCenterRepository.notificationSettingsCallsCount == 1)
  }

  // MARK: Private

  private let useCase: GetPushPermissionStatusUseCase
  private let pushNotificationCenterRepository: PushNotificationCenterRepositoryProtocolSpy
}
