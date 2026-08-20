import BITDataStore
import BITEIDRequestShared
import BITEntities
import Factory
import Foundation
import Spyable


@Spyable
protocol EIDRequestCaseRepositoryProtocol {
  @discardableResult
  func create(eIDRequestCase: EIDRequestCase) async throws -> EIDRequestCase
  func get(id: String) async throws -> EIDRequestCase
  func getAll() async throws -> [EIDRequestCase]
  func getAllPushIds() async throws -> [String]
  func savePushId(_ pushId: String, for caseId: String) async throws

  @discardableResult
  func update(_ eIDRequestCase: EIDRequestCase) async throws -> EIDRequestCase
  func delete(_ id: String) async throws

  // MARK: - Files

  func getFile(forRequestCaseId id: String, name: String, category: EIDRequestCaseFile.Category) async throws -> EIDRequestCaseFile
  func getAllFiles(forRequestCaseId id: String) async throws -> [EIDRequestCaseFile]
  func getFiles(forRequestCaseId id: String, matching category: EIDRequestCaseFile.Category) async throws -> [EIDRequestCaseFile]
  func save(files: [EIDRequestCaseFile], forRequestCaseId id: String) async throws
  func deleteAllFiles(forRequestCaseId id: String) async throws

  // MARK: - Pairing ID

  func savePairingId(_ pairingId: String, forRequestCaseId id: String) async throws
  func getPairingIds(forRequestCaseId id: String) async throws -> [String]
  func deletePairings(for requestCase: String) async throws
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

    try database.write {
      entity.credential = nil
    }

    try database.delete(entity)
  }

  func getFile(forRequestCaseId id: String, name: String, category: EIDRequestCaseFile.Category) async throws -> EIDRequestCaseFile {
    let file = try database.get(EIDRequestCaseFileEntity.self)
      .filter { $0.requestCase.first?.id == id && $0.category == category.rawValue && $0.fileName == name }
      .first

    guard let file else {
      throw EIDRequestCaseRepositoryError.notFound
    }

    return try EIDRequestCaseFile(file)
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

  func getAllPushIds() async throws -> [String] {
    try database.get(EIDRequestCaseEntity.self)
      .compactMap(\.pushId)
  }

  func savePushId(_ pushId: String, for caseId: String) async throws {
    let entity = try getEntity(caseId)
    try database.write {
      entity.pushId = pushId
    }
  }

  func savePairingId(_ pairingId: String, forRequestCaseId id: String) async throws {
    let entity = try getEntity(id)
    let walletPairing = EIDRequestCaseWalletEntity()
    walletPairing.pairingId = pairingId

    try database.write {
      entity.pairingIds.append(walletPairing)
    }
  }

  func getPairingIds(forRequestCaseId id: String) async throws -> [String] {
    try getEntity(id).pairingIds.compactMap(\.pairingId)
  }

  func deletePairings(for requestCase: String) async throws {
    let entity = try getEntity(requestCase)
    try database.write {
      entity.pairingIds.removeAll()
    }
  }

  // MARK: Private

  @Injected(\.dataStore) private var database
  @Injected(\.sidFilenameMap) private var filenameMap

  private func getEntity(_ id: String) throws -> EIDRequestCaseEntity {
    let results = try database.get(EIDRequestCaseEntity.self, forPrimaryKey: id)
    guard let entity = results else { throw EIDRequestCaseRepositoryError.notFound }
    return entity
  }

}
