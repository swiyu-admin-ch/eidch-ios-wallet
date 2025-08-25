// swiftlint:disable force_unwrapping
import Factory
import Foundation
import RealmSwift
import XCTest
@testable import BITDataStore
@testable import BITEntities

// MARK: - RealmMigrationTests

final class RealmMigrationTests: XCTestCase {

  // MARK: Internal

  func testMigrate() throws {
    let cases: [MigrationTestCase] = [
      MigrationTestCase(from: 4, to: 5, fileURL: Realm.Mock.version4Snapshot) { realm in
        self.testMigrate_toVersion5_createsClusterAndAppendsClaims(realm)
      },
      MigrationTestCase(from: 5, to: 6, fileURL: Realm.Mock.version5Snapshot) { realm in
        self.testMigrate_toVersion6_createsCredentialKeyBindingForExistingKeyBinding(realm)
      },
      MigrationTestCase(from: 4, to: 6, fileURL: Realm.Mock.version4Snapshot) { realm in
        self.testMigrate_toVersion5_createsClusterAndAppendsClaims(realm)
        self.testMigrate_toVersion6_createsCredentialKeyBindingForExistingKeyBinding(realm)
      },
    ]

    for testCase in cases {
      try XCTContext.runActivity(named: "migration from \(testCase.from) to \(testCase.to)") { _ in
        let copiedFile = try copyToSimulator(testCase.fileURL)
        let realm = try migrateRealm(fileURL: copiedFile, fromSchemaVersion: testCase.from, toSchemaVersion: testCase.to)
        try testCase.validate(realm)
      }
    }
  }

  func testMigrate_toVersion5_createsClusterAndAppendsClaims(_ realm: Realm) {
    let credentials: [CredentialEntity] = realm.objects(CredentialEntity.self).compactMap({ $0 })
    XCTAssertEqual(credentials.count, 3)

    // beatID
    assertCredentialClusters(credentials["1924abdf-c72a-475c-8f43-02e5d9012f71"]!, numberOfLanguages: 5, numberOfClaims: 23)
    // eLFA
    assertCredentialClusters(credentials["bbca1163-dc86-4c6c-9de0-0c4bd670090f"]!, numberOfLanguages: 5, numberOfClaims: 17, numberOfIssuerDisplays: 2)
    // uetlibergELFA
    assertCredentialClusters(credentials["fea5fc07-d64b-4539-89e9-18e03b71e5dd"]!, numberOfLanguages: 4, numberOfClaims: 16, numberOfIssuerDisplays: 2, numberOfCredentialDisplays: 2)
  }

  func testMigrate_toVersion6_createsCredentialKeyBindingForExistingKeyBinding(_ realm: Realm) {
    let credentials: [CredentialEntity] = realm.objects(CredentialEntity.self).compactMap({ $0 })
    XCTAssertEqual(credentials.count, 3)

    // betaID
    assertKeyBinding(credentials["1924abdf-c72a-475c-8f43-02e5d9012f71"])
    // eLFA
    assertKeyBinding(credentials["bbca1163-dc86-4c6c-9de0-0c4bd670090f"])
    // uetliberg (no key binding)
    XCTAssertNil(credentials["fea5fc07-d64b-4539-89e9-18e03b71e5dd"]?.keyBinding)
  }

  // MARK: Private

  private func copyToSimulator(_ fileURL: URL) throws -> URL {
    let manager = FileManager.default
    let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
    let documents = try XCTUnwrap(url)
    let destination = documents.appendingPathComponent(fileURL.lastPathComponent)
    if manager.fileExists(atPath: destination.path) {
      try manager.removeItem(at: destination)
    }
    try manager.copyItem(at: fileURL, to: destination)
    return destination
  }

  private func migrateRealm(fileURL: URL, fromSchemaVersion: UInt64, toSchemaVersion: UInt64) throws -> Realm {

    XCTAssertEqual(try schemaVersionAtURL(fileURL), fromSchemaVersion)

    var configuration = Realm.Configuration(
      schemaVersion: toSchemaVersion,
      migrationBlock: { migration, oldVersion in
        Container.shared.migrationService.resolve().migrate(from: oldVersion, to: toSchemaVersion, migration: migration)
      })

    configuration.fileURL = fileURL
    let realm = try Realm(configuration: configuration)

    XCTAssertEqual(try schemaVersionAtURL(fileURL), toSchemaVersion)

    return realm
  }

  private func assertCredentialClusters(_ credential: CredentialEntity, numberOfLanguages: Int, numberOfClaims: Int, numberOfIssuerDisplays: Int? = nil, numberOfCredentialDisplays: Int? = nil) {
    XCTAssertNotNil(credential.rawCredentialData)
    XCTAssertEqual(credential.issuerDisplays.count, numberOfIssuerDisplays ?? numberOfLanguages)
    XCTAssertEqual(credential.displays.count, numberOfCredentialDisplays ?? numberOfLanguages)

    XCTAssertEqual(credential.clusters.count, 1)
    let cluster = credential.clusters.first!
    XCTAssertEqual(cluster.childClusters.count, 0)
    XCTAssertEqual(cluster.claims.count, numberOfClaims)
    for claim in cluster.claims {
      XCTAssertEqual(claim.displays.count, numberOfLanguages)
    }
  }

  private func assertKeyBinding(_ credential: CredentialEntity?) {
    guard let credential else { return }
    XCTAssertNotNil(credential.keyBinding)
    XCTAssertEqual(credential.keyBinding?.bindingType, "hardware")
    XCTAssertNil(credential.keyBinding?.publicKey)
    XCTAssertNil(credential.keyBinding?.privateKey)
  }
}

// MARK: - MigrationTestCase

fileprivate struct MigrationTestCase {
  let from: UInt64
  let to: UInt64
  let fileURL: URL
  let validate: (Realm) throws -> Void
}

// swiftlint:enable all

extension [CredentialEntity] {
  fileprivate subscript (id: String) -> Element? {
    first(where: { $0.id.uuidString.lowercased() == id })
  }
}
