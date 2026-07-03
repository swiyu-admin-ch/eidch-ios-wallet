import Factory
import Foundation
import RealmSwift
import XCTest
@testable import BITDataStore
@testable import BITEntities

// MARK: - RealmMigrationTests

// swiftlint:disable force_unwrapping force_try

final class RealmMigrationTests: XCTestCase {

  // MARK: Internal

  func testMigrate_fromVersion1() throws {
    let realm = try createRealm(from: Realm.Mock.version1Snapshot, schemaVersion: 1)

    // first live version but no manual migrations up to next version
    assertCredentials(realm)

    assertClusters(realm)
    assertKeyBindings(realm)
    assertBundleItemsAndDeferredKeyBindingsMigration(realm)
    assertVerifiableCredentials(realm, hasValidUntil: false)
    assertProgressionState(realm)
    assertDeletionOfOrphanedObjects(realm, firstMissingDatabaseFeature: .rawCredentialData)
    assertClaimsPathPointerReplacedKey(realm)
    assertJsonPathMigratedToClaimsPathPointer(realm)
  }

  func testMigrate_fromVersion4() throws {
    let realm = try createRealm(from: Realm.Mock.version4Snapshot, schemaVersion: 4)

    assertCredentials(realm)

    assertClusters(realm)
    assertKeyBindings(realm)
    assertBundleItemsAndDeferredKeyBindingsMigration(realm)
    assertVerifiableCredentials(realm)
    assertProgressionState(realm)
    assertDeletionOfOrphanedObjects(realm, firstMissingDatabaseFeature: .cluster)
    assertClaimsPathPointerReplacedKey(realm)
    assertJsonPathMigratedToClaimsPathPointer(realm)
  }

  func testMigrate_fromVersion5() throws {
    let realm = try createRealm(from: Realm.Mock.version5Snapshot, schemaVersion: 5)

    assertCredentials(realm)

    assertKeyBindings(realm)
    assertBundleItemsAndDeferredKeyBindingsMigration(realm)
    assertVerifiableCredentials(realm)
    assertProgressionState(realm)
    assertDeletionOfOrphanedObjects(realm, firstMissingDatabaseFeature: .deferredCredential)
    assertClaimsPathPointerReplacedKey(realm)
    assertJsonPathMigratedToClaimsPathPointer(realm)
  }

  func testMigrate_fromVersion10() throws {
    let realm = try createRealm(from: Realm.Mock.version10Snapshot, schemaVersion: 10)

    assertCredentials(realm)

    assertBundleItemsAndDeferredKeyBindingsMigration(realm)
    assertVerifiableCredentials(realm)
    assertProgressionState(realm)
    assertDeletionOfOrphanedObjects(realm, firstMissingDatabaseFeature: .deferredCredential)
    assertClaimsPathPointerReplacedKey(realm)
    assertJsonPathMigratedToClaimsPathPointer(realm)
  }

  func testMigrate_fromVersion14() throws {
    let realm = try createRealm(from: Realm.Mock.version14Snapshot, schemaVersion: 14)

    assertCredentials(realm, hasDeferredCredential: true)

    assertBundleItemsAndDeferredKeyBindingsMigration(realm, hasDeferredCredential: true)
    assertProgressionState(realm)
    assertDeletionOfOrphanedObjects(realm)
    assertClaimsPathPointerReplacedKey(realm)
    assertJsonPathMigratedToClaimsPathPointer(realm)
  }

  func testMigrate_fromVersion16() throws {
    let realm = try createRealm(from: Realm.Mock.version16Snapshot, schemaVersion: 16)

    assertCredentials(realm, hasDeferredCredential: true)

    assertBundleItemsAndDeferredKeyBindingsMigration(realm, hasDeferredCredential: true)
    assertDeletionOfOrphanedObjects(realm)
    assertClaimsPathPointerReplacedKey(realm)
    assertJsonPathMigratedToClaimsPathPointer(realm)
  }

  func testMigrate_fromVersion23() throws {
    let realm = try createRealm(from: Realm.Mock.version23Snapshot, schemaVersion: 23)

    assertCredentials(realm, hasDeferredCredential: true)

    assertClaimsPathPointerReplacedKey(realm)
    assertJsonPathMigratedToClaimsPathPointer(realm)
  }

  func testMigrate_fromVersion26() throws {
    let realm = try createRealm(from: Realm.Mock.version26Snapshot, schemaVersion: 26)

    assertCredentials(realm, hasDeferredCredential: true)

    assertJsonPathMigratedToClaimsPathPointer(realm)
  }

  // MARK: Private

  private static let currentSchemaVersion: UInt64 = 29

  private func createRealm(from fileURL: URL, schemaVersion: UInt64) throws -> Realm {
    let copiedFile = try copyToSimulator(fileURL)
    return try migrateRealm(fileURL: copiedFile, fromSchemaVersion: schemaVersion)
  }

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

  private func migrateRealm(fileURL: URL, fromSchemaVersion: UInt64, toSchemaVersion: UInt64 = currentSchemaVersion) throws -> Realm {

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

  private func assertCredentials(_ realm: Realm, hasDeferredCredential: Bool = false) {
    let credentials: [CredentialEntity] = realm.objects(CredentialEntity.self).compactMap({ $0 })
    XCTAssertEqual(credentials.count, hasDeferredCredential ? 4 : 3)

    assertCredentialClaimsAndDisplays(credentials["82407f9a-5f47-40d7-a67b-2e59e311cada"]!, numberOfLanguages: 5, numberOfClaims: 23)
    assertCredentialClaimsAndDisplays(credentials["e5d7121f-683c-4775-8cf7-d415de4e339c"]!, numberOfLanguages: 5, numberOfClaims: 17, numberOfIssuerDisplays: 5)
    assertCredentialClaimsAndDisplays(credentials["84912164-8775-4d14-bf7e-ff08a21b979f"]!, numberOfLanguages: 2, numberOfClaims: 17, numberOfIssuerDisplays: 2, numberOfCredentialDisplays: 2, numberOfCredentialClaimDisplays: 4)
    if hasDeferredCredential {
      XCTAssertNotNil(credentials["630c76ed-e712-4f1a-ae7e-6842ee5fa60a"]?.deferredCredential)
    }
  }

  private func assertCredentialClaimsAndDisplays(_ credential: CredentialEntity, numberOfLanguages: Int, numberOfClaims: Int, numberOfIssuerDisplays: Int? = nil, numberOfCredentialDisplays: Int? = nil, numberOfCredentialClaimDisplays: Int? = nil) {
    XCTAssertEqual(credential.issuerDisplays.count, numberOfIssuerDisplays ?? numberOfLanguages)
    XCTAssertEqual(credential.displays.count, numberOfCredentialDisplays ?? numberOfLanguages)

    XCTAssertEqual(credential.verifiableCredential?.clusters.count, 1)
    let cluster = credential.verifiableCredential!.clusters.first!
    XCTAssertEqual(cluster.claims.count, numberOfClaims)
    for claim in cluster.claims {
      XCTAssertEqual(claim.displays.count, numberOfCredentialClaimDisplays ?? numberOfLanguages)
      guard
        let data = claim.path.data(using: .utf8),
        let pointer = try? JSONSerialization.jsonObject(with: data) as? [String]
      else {
        XCTFail("not a valid claims path pointer string: \(claim.path)")
        continue
      }

      XCTAssertEqual(pointer.count, 1)
    }
  }

  private func assertClaimsPathPointerReplacedKey(_ realm: Realm) {
    let claims = realm.objects(CredentialClaimEntity.self)

    assertClaim(claims, path: "[\"lastName\"]", value: "Muster")
    assertClaim(claims, path: "[\"hometown\"]", value: "Entenhausen")
    assertClaim(claims, path: "[\"issuerEntity\"]", value: "Chasseral-Test")
    assertClaim(claims, path: "[\"categoryCode\"]", value: "B")
  }

  private func assertJsonPathMigratedToClaimsPathPointer(_ realm: Realm) {
    let summaries = realm.objects(CredentialDisplayEntity.self).compactMap(\.summary)

    XCTAssertTrue(summaries.contains("Categoria {{[\"categoryCode\"]}}"))
    XCTAssertTrue(summaries.contains("Catégorie {{[\"categoryCode\"]}}"))
    XCTAssertTrue(summaries.contains("Category {{[\"categoryCode\"]}}"))
    XCTAssertTrue(summaries.contains("Kategorie {{[\"categoryCode\"]}}"))
  }

  private func assertClaim(_ claims: Results<CredentialClaimEntity>, path: String, value: String) {
    XCTAssertTrue(
      claims.contains(where: { $0.path == path && $0.value == value }),
      "Missing claim with path \(path) and value \(value)")
  }

  private func assertClusters(_ realm: Realm) {
    let credentials: [CredentialEntity] = realm.objects(CredentialEntity.self).compactMap({ $0 })
    XCTAssertEqual(credentials.count, 3)

    for credential in credentials {
      XCTAssertEqual(credential.verifiableCredential?.clusters.count, 1)
      let cluster = credential.verifiableCredential!.clusters.first!
      XCTAssertEqual(cluster.childClusters.count, 0)
      XCTAssertTrue(!cluster.claims.isEmpty)
    }
  }

  private func assertKeyBindings(_ realm: Realm) {
    let bindings: [CredentialKeyBindingEntity] = realm.objects(CredentialKeyBindingEntity.self).compactMap({ $0 })
    XCTAssertEqual(bindings.count, 3)
    for binding in bindings {
      assertKeyBinding(binding, algorithm: "ES256", bindingType: "hardware")
    }
  }

  private func assertVerifiableCredentials(_ realm: Realm, hasValidUntil: Bool = true) {
    let credentials: [CredentialEntity] = realm.objects(CredentialEntity.self).compactMap({ $0 })
    XCTAssertEqual(credentials.count, 3)

    for credential in credentials {
      guard let verifiableCredential = credential.verifiableCredential else {
        XCTFail("Missing verifiable credential for \(credential.id)")
        continue
      }

      XCTAssertTrue(
        verifiableCredential.bundleItems.contains(where: { $0.id == verifiableCredential.nextPresentableBundleItemId }),
        "Missing bundle item for nextPresentableBundleItemId on \(credential.id)")
    }

    assertVerifiableCredential(
      credentials["84912164-8775-4d14-bf7e-ff08a21b979f"]!,
      issuer: "did:tdw:QmXteH1UtiERDjYSYd4xqG8QEBnwkqw7P9GHv6JQ9xqfNK:identifier-reg-r.trust-infra.swiyu.admin.ch:api:v1:did:b6aca1a5-8d71-4cfc-ad50-7f73314399b7",
      payloadCount: 584950,
      keyBindingId: "AFEED6F6-B3EC-41F6-B4EB-440BEB7BAD97",
      validFrom: Date(timeIntervalSinceReferenceDate: 732960000),
      validUntil: hasValidUntil ? Date(timeIntervalSinceReferenceDate: 851990400) : nil) // chasseral

    assertVerifiableCredential(
      credentials["82407f9a-5f47-40d7-a67b-2e59e311cada"]!,
      issuer: "did:tdw:QmRhsT9rVEQWc2xqk19Lvgqo5qE5ufPqsujkbPSvZDNPUg:identifier-reg-a.trust-infra.swiyu-int.admin.ch:api:v1:did:3761f0a3-f7c1-44a0-bab9-aa7a4a4bc596",
      payloadCount: 170047,
      keyBindingId: "1C870514-85D5-4EF6-83CE-B2D4D2580833",
      validFrom: nil,
      validUntil: nil) // BCS

    assertVerifiableCredential(
      credentials["e5d7121f-683c-4775-8cf7-d415de4e339c"]!,
      issuer: "did:tdw:QmXuXpFHTpTVc8JkSpAvo5gKrxXmiw5sBPgVBPPko9kFNd:identifier-reg-r.trust-infra.swiyu.admin.ch:api:v1:did:170f8027-bc5b-4a38-96a3-5037257d3701",
      payloadCount: 67045,
      keyBindingId: "A0822BB1-B99F-45DF-BB56-DE1C8A96C00A",
      validFrom: Date(timeIntervalSinceReferenceDate: 746575200),
      validUntil: hasValidUntil ? Date(timeIntervalSinceReferenceDate: 851990400) : nil) // eLFA
  }

  private func assertVerifiableCredential(
    _ credential: CredentialEntity,
    status: BundleItemEntity.CredentialStatus = .valid,
    progressionState: VerifiableCredentialEntity.ProgressionState = .accepted,
    issuer: String,
    payloadCount: Int,
    keyBindingId: String,
    validFrom: Date? = nil,
    validUntil: Date? = nil)
  {
    XCTAssertNil(credential.eIDRequestCase)
    XCTAssertNil(credential.deferredCredential)
    let authentication = try! XCTUnwrap(credential.authentication)
    guard let vc = credential.verifiableCredential else {
      XCTFail("No verifiable credential found for \(credential.id)")
      return
    }

    XCTAssertEqual(authentication.tokenType, "bearer")
    XCTAssertEqual(vc.progressionState, progressionState)
    XCTAssertEqual(vc.issuer, issuer)
    XCTAssertEqual(vc.bundleItems.count, 1)
    XCTAssertEqual(vc.bundleItems.first?.payload.count, payloadCount)
    XCTAssertEqual(vc.bundleItems.first?.status, status)
    XCTAssertEqual(vc.bundleItems.first?.presented, false)
    XCTAssertEqual(vc.bundleItems.first?.keyBinding?.id.uuidString, keyBindingId)
    XCTAssertEqual(vc.nextPresentableBundleItemId, vc.bundleItems.first?.id)
    XCTAssertEqual(vc.validFrom, validFrom)
    XCTAssertEqual(vc.validUntil, validUntil)
    XCTAssertEqual(vc.clusters.count, 1)
  }

  private func assertProgressionState(_ realm: Realm) {
    let credentials: [CredentialEntity] = realm.objects(CredentialEntity.self).compactMap({ $0 })
    for credential in credentials {
      if let vc = credential.verifiableCredential {
        XCTAssertEqual(vc.progressionState, .accepted)
      }
    }
  }

  private func assertBundleItemsAndDeferredKeyBindingsMigration(_ realm: Realm, hasDeferredCredential: Bool = false) {
    let credentials: [CredentialEntity] = realm.objects(CredentialEntity.self).compactMap({ $0 })

    let keyBindingIdsByCredentialId = [
      "82407f9a-5f47-40d7-a67b-2e59e311cada": "1C870514-85D5-4EF6-83CE-B2D4D2580833",
      "84912164-8775-4d14-bf7e-ff08a21b979f": "AFEED6F6-B3EC-41F6-B4EB-440BEB7BAD97",
      "e5d7121f-683c-4775-8cf7-d415de4e339c": "A0822BB1-B99F-45DF-BB56-DE1C8A96C00A",
    ]

    for (credentialId, keyBindingId) in keyBindingIdsByCredentialId {
      guard let credential = credentials[credentialId], let verifiableCredential = credential.verifiableCredential else {
        XCTFail("Missing verifiable credential with id \(credentialId)")
        continue
      }
      XCTAssertEqual(verifiableCredential.bundleItems.count, 1)
      XCTAssertEqual(verifiableCredential.bundleItems.first?.presented, false)
      XCTAssertEqual(verifiableCredential.nextPresentableBundleItemId, verifiableCredential.bundleItems.first?.id)
      assertKeyBinding(verifiableCredential.bundleItems.first?.keyBinding, id: keyBindingId, algorithm: "ES256", bindingType: "hardware")
    }

    guard hasDeferredCredential else {
      return
    }

    guard let deferredCredentialOwnerId = UUID(uuidString: "630c76ed-e712-4f1a-ae7e-6842ee5fa60a") else {
      XCTFail("Invalid deferred credential id")
      return
    }

    let credential = realm.object(ofType: CredentialEntity.self, forPrimaryKey: deferredCredentialOwnerId)
    guard let credential, let deferredCredential = credential.deferredCredential else {
      XCTFail("Missing deferred credential")
      return
    }

    XCTAssertEqual(deferredCredential.keyBindings.count, 1)
    assertKeyBinding(deferredCredential.keyBindings.first, algorithm: "ES256", bindingType: "software")

    let authentication = try! XCTUnwrap(credential.authentication)
    XCTAssertEqual(authentication.accessToken, "dc7c4681-2fc4-454a-9d3f-0997926cf8d5")
    XCTAssertEqual(authentication.tokenType, "bearer")
    XCTAssertNil(authentication.refreshToken)
    XCTAssertNil(authentication.dpopBinding)
  }

  private func assertKeyBinding(_ keyBinding: CredentialKeyBindingEntity?, id: String? = nil, algorithm: String, bindingType: String) {
    guard let keyBinding else {
      XCTFail("Missing key binding")
      return
    }

    if let id {
      XCTAssertEqual(keyBinding.id.uuidString, id)
    }
    XCTAssertEqual(keyBinding.algorithm, algorithm)
    XCTAssertEqual(keyBinding.bindingType, bindingType)
    if bindingType == "hardware" {
      XCTAssertNil(keyBinding.publicKey)
      XCTAssertNil(keyBinding.privateKey)
    } else if bindingType == "software" {
      XCTAssertNotNil(keyBinding.publicKey)
      XCTAssertNotNil(keyBinding.privateKey)
      XCTAssertEqual(keyBinding.publicKey?.count, 65)
      XCTAssertEqual(keyBinding.privateKey?.count, 97)
    }
  }

  private func assertDeletionOfOrphanedObjects(_ realm: Realm, firstMissingDatabaseFeature: DatabaseFeature = .none) {
    XCTAssertEqual(realm.objects(CredentialKeyBindingEntity.self).count, firstMissingDatabaseFeature.getKeyBindingCount())
    XCTAssertEqual(realm.objects(BundleItemEntity.self).count, 3)
    XCTAssertEqual(realm.objects(RawCredentialDataEntity.self).count, firstMissingDatabaseFeature.getRawCredentialDataCount())
    XCTAssertEqual(realm.objects(DPoPBindingEntity.self).count, 0)
    XCTAssertEqual(realm.objects(DeferredCredentialEntity.self).count, firstMissingDatabaseFeature.getDeferredCredentialCount())
    XCTAssertEqual(realm.objects(BatchDataEntity.self).count, 0)
    XCTAssertEqual(realm.objects(VerifiableCredentialEntity.self).count, 3)
    XCTAssertEqual(realm.objects(CredentialIssuerDisplayEntity.self).count, firstMissingDatabaseFeature.getCredentialIssuerDisplayCount())
    XCTAssertEqual(realm.objects(CredentialDisplayEntity.self).count, firstMissingDatabaseFeature.getCredentialDisplayCount())
    XCTAssertEqual(realm.objects(CredentialClaimClusterEntity.self).count, 3)
    XCTAssertEqual(realm.objects(CredentialClaimClusterDisplayEntity.self).count, firstMissingDatabaseFeature.getCredentialClaimClusterDisplayCount())
    XCTAssertEqual(realm.objects(CredentialClaimEntity.self).count, 57)
    XCTAssertEqual(realm.objects(CredentialClaimDisplayEntity.self).count, 268)
    XCTAssertEqual(realm.objects(EIDRequestStateEntity.self).count, 0)
  }
}

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
