import Testing
@testable import BITAppInfo

struct DisabledVersionEnforcementUseCaseTests {

  // MARK: Internal

  @Test
  func callAsFunction_returnsNil() async throws {
    let useCase = DisabledVersionEnforcementUseCase()

    let versionEnforcement = try await useCase()

    #expect(versionEnforcement == nil)
  }
}
