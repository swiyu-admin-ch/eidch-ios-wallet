// MARK: - DisabledVersionEnforcementUseCase

public struct DisabledVersionEnforcementUseCase: FetchVersionEnforcementUseCaseProtocol {

  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public func callAsFunction() async throws -> VersionEnforcement? {
    nil
  }
}
