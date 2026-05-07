import BITActivity
import BITEntities
import Combine
import Factory
import Foundation

class LocalActivityRepository: ActivityRepositoryProtocol {

  // MARK: Internal

  var activityHistoryEnabledSubject = CurrentValueSubject<Bool, Never>(true)

  func deleteAll() throws {
    activities.removeAll()
  }

  func isActivityHistoryEnabled() throws -> Bool {
    true
  }

  func setActivityHistoryEnabled(_ isEnabled: Bool) throws {}

  func create(_ activity: Activity, credentialId: UUID) throws -> UUID {
    activities.append(activity)
    return activity.id
  }

  func getDetail(_ id: UUID) throws -> ActivityDetail {
    guard let activity = activities.first(where: { $0.id == id }) else {
      throw NSError(domain: "ActivityRepositoryLocal", code: 404)
    }
    let entity = CredentialActivityEntity(activity)
    return try activityDetailFactory(entity)
  }

  func getAll(for credentialId: UUID, limit: Int) throws -> [ActivityListItem] {
    activities
      .prefix(limit)
      .map(CredentialActivityEntity.init)
      .map(activityListItemFactory.callAsFunction)
  }

  func delete(_ id: UUID) throws {
    activities.removeAll { $0.id == id }
  }

  func deleteAll(for credentialId: UUID) throws {
    activities.removeAll()
  }

  // MARK: Private

  private var activities = [Activity]()
  @Injected(\.activityDetailFactory) private var activityDetailFactory
  @Injected(\.activityListItemFactory) private var activityListItemFactory

}
