import BITActivity
import Foundation

class LocalActivityRepository: ActivityRepositoryProtocol {

  // MARK: Internal

  func create(_ activity: Activity, credentialId: UUID) throws -> Activity {
    var newActivity = activity
    activities.append(newActivity)
    return newActivity
  }

  func get(_ id: UUID) throws -> Activity {
    guard let activity = activities.first(where: { $0.id == id }) else {
      throw NSError(domain: "ActivityRepositoryLocal", code: 404)
    }
    return activity
  }

  func getAll(for credentialId: UUID, limit: Int) throws -> [Activity] {
    activities
      .prefix(limit)
      .map { $0 }
  }

  func delete(_ id: UUID) throws {
    activities.removeAll { $0.id == id }
  }

  func deleteAll(for credentialId: UUID) throws {
    activities.removeAll()
  }

  // MARK: Private

  private var activities = [Activity]()

}
