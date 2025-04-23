import BITDataStore
import BITEntities
import Factory
import Foundation


enum DatabaseEIDRequestRepositoryError: Error {
  case notFound
}


struct DatabaseEIDRequestRepository: LocalEIDRequestRepositoryProtocol {

  // MARK: Internal

  func create(eIDRequestCase: EIDRequestCase) async throws -> EIDRequestCase {
    let entity = try EIDRequestCaseEntity(eIDRequestCase)
    try database.save(entity)
    return try EIDRequestCase(entity)
  }

  func get(id: String) async throws -> EIDRequestCase {
    let entity = try await getEntity(id)
    return try EIDRequestCase(entity)
  }

  func getAll() throws -> [EIDRequestCase] {
    let results = try database.get(EIDRequestCaseEntity.self)
      .sorted { $0.createdAt > $1.createdAt }
      .map(EIDRequestCase.init)

    return results
  }

  func update(_ eIDRequestCase: EIDRequestCase) async throws -> EIDRequestCase {
    let entity = try await getEntity(eIDRequestCase.id)

    try database.write({
      try entity.setValues(from: eIDRequestCase)
    })

    return try EIDRequestCase(entity)
  }

  func delete(_ eIDRequestCase: EIDRequestCase) async throws {
    let entity = try await getEntity(eIDRequestCase.id)
    try database.delete(entity)
  }

  // MARK: Private

  @Injected(\.dataStore) private var database: RealmDataStoreProtocol

  private func getEntity(_ id: String) async throws -> EIDRequestCaseEntity {
    let results = try database.get(EIDRequestCaseEntity.self, forPrimaryKey: id)
    guard let entity = results else { throw DatabaseEIDRequestRepositoryError.notFound }
    return entity
  }

}
