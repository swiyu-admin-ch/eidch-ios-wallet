import Foundation
import Spyable

@Spyable
protocol VersionEnforcementRepositoryProtocol: Sendable {
  func fetchVersionEnforcement() async throws -> VersionEnforcement.Response
}
