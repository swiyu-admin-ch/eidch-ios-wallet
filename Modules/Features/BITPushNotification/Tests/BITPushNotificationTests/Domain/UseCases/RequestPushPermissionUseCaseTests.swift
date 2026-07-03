import BITTestingCore
import Factory
import Testing
@testable import BITPushNotification

struct RequestPushPermissionUseCaseTests {

  // MARK: Lifecycle

  init() {
    let pushNotificationCenterRepository = PushNotificationCenterRepositoryProtocolSpy()
    self.pushNotificationCenterRepository = pushNotificationCenterRepository

    Container.shared.pushNotificationCenterRepository.register { pushNotificationCenterRepository }

    useCase = RequestPushPermissionUseCase()
  }

  // MARK: Internal

  @Test(arguments: [true, false])
  func requestPermission_returnsServiceResult(isAuthorized: Bool) async throws {
    pushNotificationCenterRepository.requestAuthorizationOptionsReturnValue = isAuthorized

    let result = try await useCase()

    #expect(result == isAuthorized)
    #expect(pushNotificationCenterRepository.requestAuthorizationOptionsCallsCount == 1)
    #expect(pushNotificationCenterRepository.requestAuthorizationOptionsReceivedOptions == [.alert, .badge, .sound])
  }

  @Test
  func requestPermission_serviceThrows_throwsError() async {
    pushNotificationCenterRepository.requestAuthorizationOptionsThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await useCase()
    }
  }

  // MARK: Private

  private let useCase: RequestPushPermissionUseCase
  private let pushNotificationCenterRepository: PushNotificationCenterRepositoryProtocolSpy

}
