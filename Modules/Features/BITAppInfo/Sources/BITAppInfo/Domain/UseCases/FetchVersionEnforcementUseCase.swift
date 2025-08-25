import Factory
import Foundation
import Spyable

// MARK: - FetchVersionEnforcementUseCaseProtocol

@Spyable
public protocol FetchVersionEnforcementUseCaseProtocol {
  func execute(withTimeout: UInt64) async throws -> VersionEnforcement?
}

// MARK: - FetchVersionEnforcementUseCase

struct FetchVersionEnforcementUseCase: FetchVersionEnforcementUseCaseProtocol {

  // MARK: Lifecycle

  init(repository: VersionEnforcementRepositoryProtocol = Container.shared.versionEnforcementRepository(), getAppVersionUseCase: GetAppVersionUseCaseProtocol = Container.shared.getAppVersionUseCase()) {
    self.repository = repository
    self.getAppVersionUseCase = getAppVersionUseCase
  }

  // MARK: Internal

  func execute(withTimeout: UInt64) async throws -> VersionEnforcement? {
    let getVersionEnforcementStateTask = Task {
      let versionEnforcements = try await repository.fetchVersionEnforcements()
      let taskResult = try getVersionEnforcement(for: versionEnforcements)
      try Task.checkCancellation()

      return taskResult
    }

    let timeoutTask = Task {
      try? await Task.sleep(nanoseconds: withTimeout)
      getVersionEnforcementStateTask.cancel()
    }

    let state = try await getVersionEnforcementStateTask.value
    timeoutTask.cancel()

    return state
  }

  // MARK: Private

  private static let highPriority = "high"
  private static let iOSPlatform = "ios"

  private let repository: VersionEnforcementRepositoryProtocol
  private var getAppVersionUseCase: GetAppVersionUseCaseProtocol
}

extension FetchVersionEnforcementUseCase {

  private func getVersionEnforcement(for versionEnforcements: [VersionEnforcement]) throws -> VersionEnforcement? {
    if versionEnforcements.isEmpty {
      throw FetchVersionEnforcementUseCaseError.emptyVersionEnforcements
    }

    guard let versionEnforcement = versionEnforcements.first(where: { $0.priority == Self.highPriority && $0.platform == Self.iOSPlatform }) else {
      throw FetchVersionEnforcementUseCaseError.noValidVersionEnforcement
    }

    let appVersion = try getAppVersionUseCase.execute()
    let criteria = versionEnforcement.criteria

    if let minAppVersionIncluded = criteria.minAppVersionIncluded {
      let minAppVersion = AppVersion(minAppVersionIncluded)
      guard appVersion >= minAppVersion else {
        return nil
      }
    }

    let maxAppVersion = AppVersion(criteria.maxAppVersionExcluded)
    guard appVersion < maxAppVersion else {
      return nil
    }

    return versionEnforcement
  }
}

// MARK: FetchVersionEnforcementUseCase.FetchVersionEnforcementUseCaseError

extension FetchVersionEnforcementUseCase {
  enum FetchVersionEnforcementUseCaseError: Error {
    case emptyVersionEnforcements
    case noValidVersionEnforcement
    case cannotFindVersionEnforcementUrl
  }
}
