import Foundation
import Spyable

// MARK: - ActivityRepositoryProtocol

@Spyable
protocol ActivityRepositoryProtocol {
  func create(_ activity: Activity, credentialId: UUID) throws -> Activity
  func get(_ id: UUID) throws -> Activity
  func getAll(for credentialId: UUID, limit: Int) throws -> [Activity]
  func delete(_ id: UUID) throws
  func deleteAll(for credentialId: UUID) throws
}

extension ActivityRepositoryProtocol {
  func getAll(for credentialId: UUID) throws -> [Activity] {
    try getAll(for: credentialId, limit: Int.max)
  }
}
