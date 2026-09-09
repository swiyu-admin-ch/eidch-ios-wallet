import Foundation
import Spyable

@Spyable
public protocol SwissProfileLifecycleRepositoryProtocol {
  func fetchSwissProfiles(_ type: SwissProfile.ProfileType) async throws -> [SwissProfile]
}
