import Foundation
import Spyable

// MARK: - ActivityRepositoryProtocol

@Spyable
public protocol ActivityRepositoryProtocol {
  func create(_ activity: Activity, credentialId: UUID) throws -> Activity
  func get(_ id: UUID) throws -> Activity
  func getAll(for credentialId: UUID, limit: Int) throws -> [Activity]
  func delete(_ id: UUID) throws
  func deleteAll() throws

  func isActivityHistoryEnabled() throws -> Bool
  func setActivityHistoryEnabled(_ isEnabled: Bool) throws
}

extension ActivityRepositoryProtocol {
  func getAll(for credentialId: UUID) throws -> [Activity] {
    try getAll(for: credentialId, limit: Int.max)
  }
}
