import Foundation
import Spyable

@Spyable
public protocol SwissProfileLifecycleRepositoryProtocol: Sendable {
  func fetchSwissProfiles(_ type: SwissProfile.ProfileType) async throws -> [SwissProfile]
}
