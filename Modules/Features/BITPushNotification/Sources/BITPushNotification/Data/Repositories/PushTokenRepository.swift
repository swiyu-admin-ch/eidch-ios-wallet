import Factory
import Spyable

// MARK: - PushTokenRepositoryProtocol

@Spyable
public protocol PushTokenRepositoryProtocol {
  func get() async throws -> String
  func getCurrent() async -> String?
  func delete() async
}

// MARK: - PushTokenRepository

struct PushTokenRepository: PushTokenRepositoryProtocol {

  // MARK: Internal

  func get() async throws -> String {
    await pushDataSource.getPushToken()
  }

  func getCurrent() async -> String? {
    await pushDataSource.getCurrentPushToken()
  }

  func delete() async {
    await pushDataSource.deletePushToken()
  }

  // MARK: Private

  @Injected(\.pushDataSource) private var pushDataSource: PushDataSourceProtocol
}
