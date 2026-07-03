import BITPushNotification
import Factory
import Spyable

// MARK: - RegisterPushTokenUseCaseProtocol

@Spyable
protocol RegisterPushTokenUseCaseProtocol {
  func callAsFunction(_ pushToken: String, caseId: String) async throws
  func callAsFunction(for caseId: String) async throws
}

// MARK: - RegisterPushTokenUseCase

struct RegisterPushTokenUseCase: RegisterPushTokenUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(_ pushToken: String, caseId: String) async throws {
    try await registerPushToken(pushToken, for: caseId)
  }

  func callAsFunction(for caseId: String) async throws {
    let pushToken = try await pushTokenRepository.get()
    try await registerPushToken(pushToken, for: caseId)
  }

  // MARK: Private

  private static let platform = "ios"

  @Injected(\.pushTokenRepository) private var pushTokenRepository: PushTokenRepositoryProtocol
  @Injected(\.eIDRequestRepository) private var eIDRequestRepository: EIDRequestRepositoryProtocol
  @Injected(\.eIDRequestCaseRepository) private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocol
  @Injected(\.pushNotificationRepository) private var pushNotificationRepository: PushNotificationRepositoryProtocol

  private func registerPushToken(_ pushToken: String, for caseId: String) async throws {
    let pushRegistrationBody = PushRegistrationBody(pushDeviceToken: pushToken, platform: Self.platform)
    let pushId = try await pushNotificationRepository.register(body: pushRegistrationBody).pushId
    let body = PushIdRegistrationBody(pushId: pushId)

    try await eIDRequestRepository.registerPushId(body, caseId: caseId)
    try await eIDRequestCaseRepository.savePushId(pushId, for: caseId)
  }

}
