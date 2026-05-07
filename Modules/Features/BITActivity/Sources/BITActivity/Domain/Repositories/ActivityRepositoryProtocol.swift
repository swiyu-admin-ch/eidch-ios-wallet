import Combine
import Foundation
import Spyable

// MARK: - ActivityRepositoryProtocol

@Spyable
public protocol ActivityRepositoryProtocol {
  func create(_ activity: Activity, credentialId: UUID) throws -> UUID
  func getDetail(_ id: UUID) throws -> ActivityDetail

  func getAll(for credentialId: UUID, limit: Int) throws -> [ActivityListItem]
  func delete(_ id: UUID) throws
  func deleteAll() throws

  func isActivityHistoryEnabled() throws -> Bool
  var activityHistoryEnabledSubject: CurrentValueSubject<Bool, Never> { get }
  func setActivityHistoryEnabled(_ isEnabled: Bool) throws
}

extension ActivityRepositoryProtocol {
  func getAll(for credentialId: UUID) throws -> [ActivityListItem] {
    try getAll(for: credentialId, limit: Int.max)
  }
}
