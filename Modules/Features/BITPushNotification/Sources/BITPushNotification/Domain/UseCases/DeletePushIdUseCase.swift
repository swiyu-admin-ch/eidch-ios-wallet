import Factory
import Spyable

// MARK: - DeletePushIdUseCaseProtocol

@Spyable
public protocol DeletePushIdUseCaseProtocol {
  func callAsFunction(_ pushId: String) async throws
}

// MARK: - DeletePushIdUseCase

struct DeletePushIdUseCase: DeletePushIdUseCaseProtocol {

  func callAsFunction(_ pushId: String) async throws {
    try await pushNotificationRepository.delete(pushId: pushId)
  }

  @Injected(\.pushNotificationRepository) private var pushNotificationRepository: PushNotificationRepositoryProtocol
}
