import BITPushNotification
import Factory
import Spyable

// MARK: - UpdatePushTokenUseCaseProtocol

@Spyable
public protocol UpdatePushTokenUseCaseProtocol {
  func callAsFunction() async throws
}

// MARK: - UpdatePushTokenUseCase

struct UpdatePushTokenUseCase: UpdatePushTokenUseCaseProtocol {

  // MARK: Internal

  func callAsFunction() async throws {
    guard let pushToken = await pushTokenRepository.getCurrent() else {
      return
    }

    let pushIds = try await eIDRequestCaseRepository.getAllPushIds()

    if pushIds.isEmpty {
      return
    }

    let pushUpdateBody = PushUpdateBody(pushIds: pushIds, pushDeviceToken: pushToken)

    try await pushNotificationRepository.update(body: pushUpdateBody)
  }

  // MARK: Private

  @Injected(\.pushTokenRepository) private var pushTokenRepository: PushTokenRepositoryProtocol
  @Injected(\.eIDRequestCaseRepository) private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocol
  @Injected(\.pushNotificationRepository) private var pushNotificationRepository: PushNotificationRepositoryProtocol
}
