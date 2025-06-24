// swiftlint:disable force_unwrapping
import Factory
import Foundation
import RealmSwift
import XCTest
@testable import BITDataStore
@testable import BITEntities

final class RealmMigrationTests: XCTestCase {

  // MARK: Internal

  func testMigrate_migrate4To5_createsClusterAndAppendsClaims() throws {
    let copiedFile = try copyToSimulator(Realm.Mock.migrationTo5URL)

    let realm = try migrateRealm(fileURL: copiedFile, fromSchemaVersion: 4, toSchemaVersion: 5)

    let credentials = realm.objects(CredentialEntity.self)
    XCTAssertEqual(credentials.count, 3)

    let betaID = credentials.first { $0.id.uuidString.lowercased() == "1924abdf-c72a-475c-8f43-02e5d9012f71" }!
    let eLFA = credentials.first { $0.id.uuidString.lowercased() == "bbca1163-dc86-4c6c-9de0-0c4bd670090f" }!
    let uetlibergELFA = credentials.first { $0.id.uuidString.lowercased() == "fea5fc07-d64b-4539-89e9-18e03b71e5dd" }!

    assertCredential(betaID, numberOfLanguages: 5, numberOfClaims: 23)
    assertCredential(eLFA, numberOfLanguages: 5, numberOfClaims: 17, numberOfIssuerDisplays: 2)
    assertCredential(uetlibergELFA, numberOfLanguages: 4, numberOfClaims: 16, numberOfIssuerDisplays: 2, numberOfCredentialDisplays: 2)
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

    var configuration = Container.shared.realmDataStoreConfiguration.resolve()
    configuration.fileURL = fileURL
    let realm = try Realm(configuration: configuration)

    XCTAssertEqual(try schemaVersionAtURL(fileURL), toSchemaVersion)

    return realm
  }

  private func assertCredential(_ credential: CredentialEntity, numberOfLanguages: Int, numberOfClaims: Int, numberOfIssuerDisplays: Int? = nil, numberOfCredentialDisplays: Int? = nil) {
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
}

// swiftlint:enable all
