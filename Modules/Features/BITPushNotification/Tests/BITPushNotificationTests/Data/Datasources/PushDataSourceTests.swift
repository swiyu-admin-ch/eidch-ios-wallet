import Foundation
import Testing
@testable import BITPushNotification

final class PushDataSourceTests {

  // MARK: Lifecycle

  deinit {
    UserDefaults.standard.removeObject(forKey: key)
  }

  // MARK: Internal

  @Test
  func getPushToken_success() async {
    UserDefaults.standard.set(mockPushToken, forKey: key)

    let pushToken = await dataSource.getPushToken()

    #expect(pushToken == mockPushToken)
  }

  @Test
  func getPushToken_withMultipleCallers_returnsPushTokenToAll() async {
    async let firstPushToken = dataSource.getPushToken()
    async let secondPushToken = dataSource.getPushToken()

    await dataSource.setPushToken(mockPushToken)

    #expect(await firstPushToken == mockPushToken)
    #expect(await secondPushToken == mockPushToken)
  }

  @Test
  func getCurrentPushToken_success() async {
    UserDefaults.standard.set(mockPushToken, forKey: key)

    let receivedPushToken = await dataSource.getCurrentPushToken()

    #expect(receivedPushToken == mockPushToken)
  }

  @Test
  func getCurrentPushToken_withoutPushToken_returnsNil() async {
    let receivedPushToken = await dataSource.getCurrentPushToken()

    #expect(receivedPushToken == nil)
  }

  @Test
  func setPushToken_success() async {
    await dataSource.setPushToken(mockPushToken)

    let pushToken = await dataSource.getPushToken()

    #expect(pushToken == mockPushToken)
  }

  @Test
  func deletePushToken_success() async {
    UserDefaults.standard.set(mockPushToken, forKey: key)

    await dataSource.deletePushToken()

    #expect(UserDefaults.standard.string(forKey: key) == nil)
  }

  // MARK: Private

  private let key = "pushToken"

  private let dataSource = PushDataSource()
  private let mockPushToken = "mockPushToken"

}
