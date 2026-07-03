import BITCore
import Factory
import Spyable

// MARK: - EnablePushNotificationsUseCaseProtocol

@Spyable @MainActor
protocol EnablePushNotificationsUseCaseProtocol {
  func callAsFunction(for caseId: String) async throws
}

// MARK: - EnablePushNotificationsUseCase

@MainActor
struct EnablePushNotificationsUseCase: EnablePushNotificationsUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(for caseId: String) async throws {
    applicationService.registerForRemoteNotifications()
    try await registerPushTokenUseCase(for: caseId)
  }

  // MARK: Private

  @Injected(\.applicationService) private var applicationService: ApplicationServiceProtocol
  @Injected(\.registerPushTokenUseCase) private var registerPushTokenUseCase: RegisterPushTokenUseCaseProtocol
}
