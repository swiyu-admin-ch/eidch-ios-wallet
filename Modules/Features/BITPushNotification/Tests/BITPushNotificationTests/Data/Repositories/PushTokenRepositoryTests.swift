import Factory
import Testing
@testable import BITPushNotification

struct PushTokenRepositoryTests {

  // MARK: Lifecycle

  init() {
    let pushDataSource = PushDataSourceProtocolSpy()
    self.pushDataSource = pushDataSource

    Container.shared.pushDataSource.register { pushDataSource }

    repository = PushTokenRepository()
  }

  // MARK: Internal

  @Test
  func get_returnsPushToken() async throws {
    pushDataSource.getPushTokenReturnValue = mockPushToken

    let receivedPushToken = try await repository.get()

    #expect(receivedPushToken == mockPushToken)
    #expect(pushDataSource.getPushTokenCallsCount == 1)
  }

  @Test
  func getCurrent_returnsPushToken() async {
    pushDataSource.getCurrentPushTokenReturnValue = mockPushToken

    let receivedPushToken = await repository.getCurrent()

    #expect(receivedPushToken == mockPushToken)
    #expect(pushDataSource.getCurrentPushTokenCallsCount == 1)
  }

  @Test
  func getCurrent_withoutPushToken_returnsNil() async {
    let receivedPushToken = await repository.getCurrent()

    #expect(receivedPushToken == nil)
    #expect(pushDataSource.getCurrentPushTokenCallsCount == 1)
  }

  @Test
  func delete_deletesPushToken() async {
    await repository.delete()

    #expect(pushDataSource.deletePushTokenCallsCount == 1)
  }

  // MARK: Private

  private let mockPushToken = "mockPushToken"

  private let repository: PushTokenRepository
  private let pushDataSource: PushDataSourceProtocolSpy
}
