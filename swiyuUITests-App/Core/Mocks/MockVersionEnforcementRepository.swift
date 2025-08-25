import BITAppInfo
import Foundation

// MARK: - MockVersionEnforcementRepository

struct MockVersionEnforcementRepository: VersionEnforcementRepositoryProtocol {
  func fetchVersionEnforcements() async throws -> [VersionEnforcement] {
    [VersionEnforcement.Mock.sample]
  }
}

// MARK: - VersionEnforcement.Mock

extension VersionEnforcement {
  struct Mock {
    static let sample: VersionEnforcement = Mocker.decode(fromFile: "version-enforcement-ui-mocks")
  }
}
