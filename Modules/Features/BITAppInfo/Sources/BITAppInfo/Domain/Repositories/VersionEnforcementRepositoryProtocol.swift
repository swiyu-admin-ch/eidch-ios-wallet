import Foundation
import Spyable

@Spyable
protocol VersionEnforcementRepositoryProtocol {
  func fetchVersionEnforcement() async throws -> VersionEnforcement.Response
}
