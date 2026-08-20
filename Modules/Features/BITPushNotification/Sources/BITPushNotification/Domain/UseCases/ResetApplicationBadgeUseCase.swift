import Factory
import Spyable

// MARK: - ResetApplicationBadgeUseCaseProtocol

@Spyable
public protocol ResetApplicationBadgeUseCaseProtocol {
  func callAsFunction() async throws
}

// MARK: - ResetApplicationBadgeUseCase

struct ResetApplicationBadgeUseCase: ResetApplicationBadgeUseCaseProtocol {
  func callAsFunction() async throws {
    try await pushNotificationCenterRepository.setBadgeCount(0)
  }

  @Injected(\.pushNotificationCenterRepository) private var pushNotificationCenterRepository: PushNotificationCenterRepositoryProtocol
}
