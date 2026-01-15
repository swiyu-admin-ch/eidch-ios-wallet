import Factory
import Foundation
import RealmSwift
import XCTest
@testable import BITDataStore
@testable import BITEntities

// MARK: - RealmMigrationTests

// swiftlint:disable force_unwrapping

final class RealmMigrationTests: XCTestCase {

  // MARK: Internal

  func testMigrate() throws {
    let cases: [MigrationTestCase] = [
      MigrationTestCase(from: 1, fileURL: Realm.Mock.version1Snapshot) { realm in
        self.testMigrate_fromVersion1_createVerifiableCredentialWithValidUntilProperty(realm)
      },
      MigrationTestCase(from: 4, fileURL: Realm.Mock.version4Snapshot) { realm in
        self.testMigrate_fromVersion4_5_createsClusterAndAppendsClaims_createsCredentialKeyBindingForExistingKeyBinding(realm)
      },
      MigrationTestCase(from: 5, fileURL: Realm.Mock.version5Snapshot) { realm in
        self.testMigrate_fromVersion4_5_createsClusterAndAppendsClaims_createsCredentialKeyBindingForExistingKeyBinding(realm)
      },
      MigrationTestCase(from: 10, fileURL: Realm.Mock.version10Snapshot) { realm in
        self.testMigrate_fromVersion10_createVerifiableCredential(realm)
      },
      MigrationTestCase(from: 14, fileURL: Realm.Mock.version14Snapshot) { realm in
        self.testMigrate_credentialProgressionState(realm)
      },
    ]

    for testCase in cases {
      try XCTContext.runActivity(named: "migration from \(testCase.from) to \(Self.currentSchemaVersion)") { _ in
        let copiedFile = try copyToSimulator(testCase.fileURL)
        let realm = try migrateRealm(fileURL: copiedFile, fromSchemaVersion: testCase.from, toSchemaVersion: Self.currentSchemaVersion)
        try testCase.validate(realm)
      }
    }
  }

  func testMigrate_fromVersion1_createVerifiableCredentialWithValidUntilProperty(_ realm: Realm) {
    let credentials: [CredentialEntity] = realm.objects(CredentialEntity.self).compactMap({ $0 })
    XCTAssertEqual(credentials.count, 2)

    // Beta ID
    assertCredentialClusters(credentials["03e1b073-113d-4eda-9b37-d0277e7774ec"]!, numberOfLanguages: 5, numberOfClaims: 23, withRawCredentialData: false)
    assertKeyBinding(credentials["03e1b073-113d-4eda-9b37-d0277e7774ec"])
    assertDefaultValues(credentials["03e1b073-113d-4eda-9b37-d0277e7774ec"]!)

    XCTAssertNil(credentials["03e1b073-113d-4eda-9b37-d0277e7774ec"]!.verifiableCredential!.validUntil)
  }

  func testMigrate_fromVersion4_5_createsClusterAndAppendsClaims_createsCredentialKeyBindingForExistingKeyBinding(_ realm: Realm) {
    let credentials: [CredentialEntity] = realm.objects(CredentialEntity.self).compactMap({ $0 })
    XCTAssertEqual(credentials.count, 3)

    // Beta ID
    assertCredentialClusters(credentials["1924abdf-c72a-475c-8f43-02e5d9012f71"]!, numberOfLanguages: 5, numberOfClaims: 23)
    assertKeyBinding(credentials["1924abdf-c72a-475c-8f43-02e5d9012f71"])
    assertDefaultValues(credentials["1924abdf-c72a-475c-8f43-02e5d9012f71"]!)

    // eLFA
    assertCredentialClusters(credentials["bbca1163-dc86-4c6c-9de0-0c4bd670090f"]!, numberOfLanguages: 5, numberOfClaims: 17, numberOfIssuerDisplays: 2)
    assertKeyBinding(credentials["bbca1163-dc86-4c6c-9de0-0c4bd670090f"])
    assertDefaultValues(credentials["bbca1163-dc86-4c6c-9de0-0c4bd670090f"]!)

    // uetlibergELFA
    assertCredentialClusters(credentials["fea5fc07-d64b-4539-89e9-18e03b71e5dd"]!, numberOfLanguages: 4, numberOfClaims: 16, numberOfIssuerDisplays: 2, numberOfCredentialDisplays: 2)
    XCTAssertNil(credentials["fea5fc07-d64b-4539-89e9-18e03b71e5dd"]?.keyBinding)
    assertDefaultValues(credentials["fea5fc07-d64b-4539-89e9-18e03b71e5dd"]!)
  }

  func testMigrate_fromVersion10_createVerifiableCredential(_ realm: Realm) {
    let credentials: [CredentialEntity] = realm.objects(CredentialEntity.self).compactMap({ $0 })
    XCTAssertEqual(credentials.count, 3)

    assertCredentialClusters(credentials["1fe0c9e6-4d67-4531-9af5-2f336d4fe113"]!, numberOfLanguages: 5, numberOfClaims: 23)
    assertDefaultValues(credentials["1fe0c9e6-4d67-4531-9af5-2f336d4fe113"]!)

    // Verifiable credential
    XCTAssertEqual(credentials["1fe0c9e6-4d67-4531-9af5-2f336d4fe113"]!.verifiableCredential?.issuer, "did:tdw:QmPEZPhDFR4nEYSFK5bMnvECqdpf1tPTPJuWs9QrMjCumw:identifier-reg.trust-infra.swiyu-int.admin.ch:api:v1:did:9a5559f0-b81c-4368-a170-e7b4ae424527")
    XCTAssertEqual(credentials["1fe0c9e6-4d67-4531-9af5-2f336d4fe113"]!.verifiableCredential?.payload.count, 183070)
    XCTAssertNil(credentials["1fe0c9e6-4d67-4531-9af5-2f336d4fe113"]!.verifiableCredential?.validFrom)
    XCTAssertNil(credentials["1fe0c9e6-4d67-4531-9af5-2f336d4fe113"]!.verifiableCredential?.validUntil)
  }

  func testMigrate_credentialProgressionState(_ realm: Realm) {
    let credentials: [VerifiableCredentialEntity] = realm.objects(VerifiableCredentialEntity.self).compactMap({ $0 })
    XCTAssertEqual(credentials.count, 3)

    XCTAssertEqual(credentials["25796e2c-8bb8-412e-a1a4-ab5c9697dfc0"]!.progressionState, .accepted)
    XCTAssertEqual(credentials["77386f8a-12b5-4801-af38-a8fa5780edeb"]!.progressionState, .accepted)
    XCTAssertEqual(credentials["24aacf56-67e3-4573-9cbb-2774a1f7374e"]!.progressionState, .accepted)
  }

  // MARK: Private

  private static let currentSchemaVersion: UInt64 = 15

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

  private func assertCredentialClusters(_ credential: CredentialEntity, numberOfLanguages: Int, numberOfClaims: Int, numberOfIssuerDisplays: Int? = nil, numberOfCredentialDisplays: Int? = nil, withRawCredentialData: Bool = true) {
    if withRawCredentialData {
      XCTAssertNotNil(credential.rawCredentialData)
    }

    XCTAssertEqual(credential.issuerDisplays.count, numberOfIssuerDisplays ?? numberOfLanguages)
    XCTAssertEqual(credential.displays.count, numberOfCredentialDisplays ?? numberOfLanguages)

    XCTAssertEqual(credential.verifiableCredential?.clusters.count, 1)
    let cluster = credential.verifiableCredential!.clusters.first!
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

  private func assertDefaultValues(_ credential: CredentialEntity) {
    XCTAssertNil(credential.eIDRequestCase)
    XCTAssertNil(credential.deferredCredential)

    XCTAssertEqual(credential.verifiableCredential?.status, .valid)
    XCTAssertEqual(credential.verifiableCredential?.progressionState, .accepted)
  }
}

// MARK: - MigrationTestCase

fileprivate struct MigrationTestCase {
  let from: UInt64
  let fileURL: URL
  let validate: (Realm) throws -> Void
}

// swiftlint:enable all

extension [CredentialEntity] {
  fileprivate subscript (id: String) -> Element? {
    first(where: { $0.id.uuidString.lowercased() == id })
  }
}

extension [VerifiableCredentialEntity] {
  fileprivate subscript (id: String) -> Element? {
    first(where: { $0.id.uuidString.lowercased() == id })
  }
}
