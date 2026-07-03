import BITCore
import Factory
import Testing
@testable import BITEIDRequest
@testable import BITTestingCore

@MainActor
struct EnablePushNotificationsUseCaseTests {

  // MARK: Lifecycle

  init() {
    let applicationService = ApplicationServiceProtocolSpy()
    let registerPushTokenUseCase = RegisterPushTokenUseCaseProtocolSpy()

    self.applicationService = applicationService
    self.registerPushTokenUseCase = registerPushTokenUseCase

    Container.shared.applicationService.register { @MainActor in applicationService }
    Container.shared.registerPushTokenUseCase.register { @MainActor in registerPushTokenUseCase }

    useCase = EnablePushNotificationsUseCase()
  }

  // MARK: Internal

  @Test
  func callAsFunction_success() async throws {
    try await useCase(for: caseId)

    #expect(applicationService.registerForRemoteNotificationsCallsCount == 1)
    #expect(registerPushTokenUseCase.callAsFunctionForCallsCount == 1)
    #expect(registerPushTokenUseCase.callAsFunctionForReceivedCaseId == caseId)
  }

  @Test
  func callAsFunction_registerPushTokenFails_throwsError() async {
    registerPushTokenUseCase.callAsFunctionForThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      try await useCase(for: caseId)
    }

    #expect(applicationService.registerForRemoteNotificationsCallsCount == 1)
    #expect(registerPushTokenUseCase.callAsFunctionForCallsCount == 1)
  }

  // MARK: Private

  private let caseId = "case-id"

  private let useCase: EnablePushNotificationsUseCase
  private let applicationService: ApplicationServiceProtocolSpy
  private let registerPushTokenUseCase: RegisterPushTokenUseCaseProtocolSpy
}
