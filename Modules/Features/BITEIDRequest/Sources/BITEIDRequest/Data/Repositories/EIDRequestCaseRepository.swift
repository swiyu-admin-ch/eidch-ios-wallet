import BITDataStore
import BITEIDRequestShared
import BITEntities
import Factory
import Foundation
import Spyable


@Spyable
protocol EIDRequestCaseRepositoryProtocol {
  func create(eIDRequestCase: EIDRequestCase) async throws -> EIDRequestCase
  func get(id: String) async throws -> EIDRequestCase
  func getAll() async throws -> [EIDRequestCase]
  func update(_ eIDRequestCase: EIDRequestCase) async throws -> EIDRequestCase
  func delete(_ id: String) async throws

  func getAllFiles(forRequestCaseId id: String) async throws -> [EIDRequestCaseFile]
  func getFiles(forRequestCaseId id: String, matching category: EIDRequestCaseFile.Category) async throws -> [EIDRequestCaseFile]
  func save(file: EIDRequestCaseFile, forRequestCaseId id: String) async throws
  func save(files: [EIDRequestCaseFile], forRequestCaseId id: String) async throws
  func deleteAllFiles(forRequestCaseId id: String) async throws
}


enum EIDRequestCaseRepositoryError: Error {
  case notFound
}


struct EIDRequestCaseRepository: EIDRequestCaseRepositoryProtocol {

  // MARK: Internal

  func create(eIDRequestCase: EIDRequestCase) async throws -> EIDRequestCase {
    let entity = EIDRequestCaseEntity(eIDRequestCase)
    try database.save(entity)
    return try EIDRequestCase(entity)
  }

  func get(id: String) async throws -> EIDRequestCase {
    let entity = try getEntity(id)
    return try EIDRequestCase(entity)
  }

  func getAll() throws -> [EIDRequestCase] {
    try database.get(EIDRequestCaseEntity.self)
      .filter { $0.state?.state != .cancelled }
      .sorted { $0.createdAt > $1.createdAt }
      .map(EIDRequestCase.init)
  }

  func update(_ eIDRequestCase: EIDRequestCase) async throws -> EIDRequestCase {
    let entity = try getEntity(eIDRequestCase.id)

    try database.write({
      entity.setValues(from: eIDRequestCase)
    })

    return try EIDRequestCase(entity)
  }

  func delete(_ id: String) async throws {
    let entity = try getEntity(id)
    try database.delete(entity)
  }

  func getAllFiles(forRequestCaseId id: String) async throws -> [EIDRequestCaseFile] {
    let entity = try getEntity(id)
    return try entity.files.compactMap(EIDRequestCaseFile.init)
  }

  func getFiles(forRequestCaseId id: String, matching category: EIDRequestCaseFile.Category) async throws -> [EIDRequestCaseFile] {
    try database.get(EIDRequestCaseFileEntity.self)
      .filter { $0.requestCase.first?.id == id && $0.category == category.rawValue }
      .sorted { $0.createdAt < $1.createdAt }
      .map(EIDRequestCaseFile.init)
  }

  func save(file: EIDRequestCaseFile, forRequestCaseId id: String) async throws {
    let entity = try getEntity(id)
    try database.write {
      entity.files.append(EIDRequestCaseFileEntity(file))
    }
  }

  func save(files: [EIDRequestCaseFile], forRequestCaseId id: String) async throws {
    let entity = try getEntity(id)
    try database.write {
      entity.files.append(objectsIn: files.map(EIDRequestCaseFileEntity.init))
    }
  }

  func deleteAllFiles(forRequestCaseId id: String) async throws {
    let entity = try getEntity(id)
    try database.write {
      entity.files.removeAll()
    }
  }

  // MARK: Private

  @Injected(\.dataStore) private var database: RealmDataStoreProtocol

  private func getEntity(_ id: String) throws -> EIDRequestCaseEntity {
    let results = try database.get(EIDRequestCaseEntity.self, forPrimaryKey: id)
    guard let entity = results else { throw EIDRequestCaseRepositoryError.notFound }
    return entity
  }

}
