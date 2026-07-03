import Foundation
import Spyable

// MARK: - PushDataSourceProtocol

@Spyable
public protocol PushDataSourceProtocol {
  func getPushToken() async -> String
  func getCurrentPushToken() async -> String?
  func setPushToken(_ pushToken: String) async
  func deletePushToken() async
}

// MARK: - PushDataSource

actor PushDataSource: PushDataSourceProtocol {

  // MARK: Internal

  func getPushToken() async -> String {
    if let pushToken = pushToken ?? UserDefaults.standard.string(forKey: Self.key) {
      self.pushToken = pushToken
      return pushToken
    }

    return await withCheckedContinuation { continuations.append($0) }
  }

  /// Returns the push token only if it exist (does not use Continuation)
  func getCurrentPushToken() async -> String? {
    if pushToken == nil {
      pushToken = UserDefaults.standard.string(forKey: Self.key)
    }

    return pushToken
  }

  func setPushToken(_ pushToken: String) async {
    self.pushToken = pushToken
    UserDefaults.standard.set(pushToken, forKey: Self.key)

    continuations.forEach { $0.resume(returning: pushToken) }
    continuations.removeAll()
  }

  func deletePushToken() async {
    pushToken = nil
    UserDefaults.standard.removeObject(forKey: Self.key)
  }

  // MARK: Private

  private static let key = "pushToken"

  private var pushToken: String?
  private var continuations = [CheckedContinuation<String, Never>]()

}
