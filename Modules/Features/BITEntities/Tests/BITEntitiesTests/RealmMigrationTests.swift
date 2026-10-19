import Factory
import FactoryTesting
import Foundation
import RealmSwift
import Testing
@testable import BITDataStore
@testable import BITEntities

// MARK: - MigrationChecks

/// The assertions that apply to a given snapshot, so every snapshot can share one test body.
struct MigrationChecks: OptionSet, Sendable {
  let rawValue: Int

  static let credentials = MigrationChecks(rawValue: 1 << 0)
  static let clusters = MigrationChecks(rawValue: 1 << 1)
  static let keyBindings = MigrationChecks(rawValue: 1 << 2)
  static let bundleItems = MigrationChecks(rawValue: 1 << 3)
  static let verifiableCredentials = MigrationChecks(rawValue: 1 << 4)
  static let progressionState = MigrationChecks(rawValue: 1 << 5)
  static let orphanCleanup = MigrationChecks(rawValue: 1 << 6)
  static let claimsPathPointerKey = MigrationChecks(rawValue: 1 << 7)
  static let jsonPathTemplates = MigrationChecks(rawValue: 1 << 8)
  static let activities = MigrationChecks(rawValue: 1 << 9)
  static let renderings = MigrationChecks(rawValue: 1 << 10)
  static let rawCredentialData = MigrationChecks(rawValue: 1 << 11)
  static let noOrphanedRenderingRows = MigrationChecks(rawValue: 1 << 12)
}

// MARK: - MigrationCase

struct MigrationCase: Sendable, CustomTestStringConvertible {

  // MARK: Lifecycle

  init(
    schemaVersion: UInt64,
    snapshot: URL,
    checks: MigrationChecks,
    orphanCleanupBaseline: DatabaseFeature = .none,
    hasDeferredCredential: Bool = false,
    hasValidUntil: Bool = true,
    activityCount: Int = 3,
    activityClaimsCount: Int? = nil,
    activityClaimPaths: [String] = ["[\"lastName\"]"])
  {
    self.schemaVersion = schemaVersion
    self.snapshot = snapshot
    self.checks = checks
    self.orphanCleanupBaseline = orphanCleanupBaseline
    self.hasDeferredCredential = hasDeferredCredential
    self.hasValidUntil = hasValidUntil
    self.activityCount = activityCount
    self.activityClaimsCount = activityClaimsCount
    self.activityClaimPaths = activityClaimPaths
  }

  // MARK: Internal

  /// The assertions shared by every snapshot predating the activity history.
  static let preActivityHistory: MigrationChecks = [
    .credentials, .bundleItems, .verifiableCredentials, .progressionState, .orphanCleanup, .claimsPathPointerKey, .jsonPathTemplates,
  ]

  static let all: [MigrationCase] = [
    MigrationCase(
      schemaVersion: 1,
      snapshot: Realm.Mock.version1Snapshot,
      // first live version but no manual migrations up to next version
      checks: preActivityHistory.union([.clusters, .keyBindings]),
      orphanCleanupBaseline: .rawCredentialData,
      hasValidUntil: false),
    MigrationCase(
      schemaVersion: 4,
      snapshot: Realm.Mock.version4Snapshot,
      checks: preActivityHistory.union([.clusters, .keyBindings]),
      orphanCleanupBaseline: .cluster),
    MigrationCase(
      schemaVersion: 5,
      snapshot: Realm.Mock.version5Snapshot,
      checks: preActivityHistory.union(.keyBindings),
      orphanCleanupBaseline: .deferredCredential),
    MigrationCase(
      schemaVersion: 10,
      snapshot: Realm.Mock.version10Snapshot,
      checks: preActivityHistory,
      orphanCleanupBaseline: .deferredCredential),
    MigrationCase(
      schemaVersion: 14,
      snapshot: Realm.Mock.version14Snapshot,
      checks: [.credentials, .activities, .bundleItems, .progressionState, .orphanCleanup, .claimsPathPointerKey, .jsonPathTemplates],
      hasDeferredCredential: true),
    MigrationCase(
      schemaVersion: 16,
      snapshot: Realm.Mock.version16Snapshot,
      checks: [.credentials, .activities, .bundleItems, .orphanCleanup, .claimsPathPointerKey, .jsonPathTemplates],
      hasDeferredCredential: true),
    MigrationCase(
      schemaVersion: 23,
      snapshot: Realm.Mock.version23Snapshot,
      checks: [.credentials, .activities, .claimsPathPointerKey, .jsonPathTemplates],
      hasDeferredCredential: true),
    MigrationCase(
      schemaVersion: 26,
      snapshot: Realm.Mock.version26Snapshot,
      checks: [.credentials, .activities, .jsonPathTemplates],
      hasDeferredCredential: true),
    MigrationCase(
      schemaVersion: 31,
      snapshot: Realm.Mock.version31Snapshot,
      checks: [.renderings, .rawCredentialData, .activities, .noOrphanedRenderingRows],
      activityClaimsCount: 1,
      activityClaimPaths: Array(repeating: "[\"firstName\"]", count: 3)),
  ]

  let schemaVersion: UInt64
  let snapshot: URL
  let checks: MigrationChecks
  let orphanCleanupBaseline: DatabaseFeature
  let hasDeferredCredential: Bool
  let hasValidUntil: Bool
  let activityCount: Int
  let activityClaimsCount: Int?
  let activityClaimPaths: [String]

  var testDescription: String {
    "from schema version \(schemaVersion)"
  }
}

// MARK: - RealmMigrationTests

@MainActor
@Suite(.container)
struct RealmMigrationTests {

  // MARK: Internal

  @Test(arguments: MigrationCase.all)
  func migrate(_ migrationCase: MigrationCase) throws {
    let realm = try createRealm(from: migrationCase.snapshot, schemaVersion: migrationCase.schemaVersion)
    let checks = migrationCase.checks

    if checks.contains(.credentials) {
      try assertCredentials(realm, hasDeferredCredential: migrationCase.hasDeferredCredential)
    }
    if checks.contains(.renderings) {
      assertRenderings(realm)
    }
    if checks.contains(.rawCredentialData) {
      assertRawCredentialData(realm)
    }
    if checks.contains(.activities) {
      assertActivitySnapshots(realm, count: migrationCase.activityCount, claimsCount: migrationCase.activityClaimsCount)
      assertActivityClaims(realm, paths: migrationCase.activityClaimPaths)
    }
    if checks.contains(.clusters) {
      try assertClusters(realm)
    }
    if checks.contains(.keyBindings) {
      assertKeyBindings(realm)
    }
    if checks.contains(.bundleItems) {
      try assertBundleItemsAndDeferredKeyBindingsMigration(realm, hasDeferredCredential: migrationCase.hasDeferredCredential)
    }
    if checks.contains(.verifiableCredentials) {
      try assertVerifiableCredentials(realm, hasValidUntil: migrationCase.hasValidUntil)
    }
    if checks.contains(.progressionState) {
      assertProgressionState(realm)
    }
    if checks.contains(.orphanCleanup) {
      assertDeletionOfOrphanedObjects(realm, firstMissingDatabaseFeature: migrationCase.orphanCleanupBaseline)
    }
    if checks.contains(.claimsPathPointerKey) {
      assertClaimsPathPointerReplacedKey(realm)
    }
    if checks.contains(.jsonPathTemplates) {
      assertJsonPathMigratedToClaimsPathPointer(realm)
    }
    if checks.contains(.noOrphanedRenderingRows) {
      assertNoOrphanedRenderingRows(realm)
    }
  }

  // MARK: Private

  private static let currentSchemaVersion: UInt64 = 32

  @Injected(\.contentHasher) private var contentHasher

  private func createRealm(from fileURL: URL, schemaVersion: UInt64) throws -> Realm {
    let copiedFile = try copyToSimulator(fileURL)
    return try migrateRealm(fileURL: copiedFile, fromSchemaVersion: schemaVersion)
  }

  private func copyToSimulator(_ fileURL: URL) throws -> URL {
    let manager = FileManager.default
    let documents = try #require(manager.urls(for: .documentDirectory, in: .userDomainMask).first)
    let destination = documents.appendingPathComponent(fileURL.lastPathComponent)
    if manager.fileExists(atPath: destination.path) {
      try manager.removeItem(at: destination)
    }
    try manager.copyItem(at: fileURL, to: destination)
    return destination
  }

  private func migrateRealm(fileURL: URL, fromSchemaVersion: UInt64, toSchemaVersion: UInt64 = currentSchemaVersion) throws -> Realm {
    let versionBeforeMigration = try schemaVersionAtURL(fileURL)
    #expect(versionBeforeMigration == fromSchemaVersion)

    var configuration = Realm.Configuration(
      schemaVersion: toSchemaVersion,
      migrationBlock: { migration, oldVersion in
        Container.shared.migrationService.resolve().migrate(from: oldVersion, to: toSchemaVersion, migration: migration)
      })

    configuration.fileURL = fileURL
    let realm = try Realm(configuration: configuration)

    let versionAfterMigration = try schemaVersionAtURL(fileURL)
    #expect(versionAfterMigration == toSchemaVersion)

    return realm
  }

  private func assertCredentials(_ realm: Realm, hasDeferredCredential: Bool) throws {
    let credentials: [CredentialEntity] = realm.objects(CredentialEntity.self).compactMap({ $0 })
    #expect(credentials.count == (hasDeferredCredential ? 4 : 3))

    try assertCredentialClaimsAndDisplays(#require(credentials["82407f9a-5f47-40d7-a67b-2e59e311cada"]), numberOfLanguages: 5, numberOfClaims: 23)
    try assertCredentialClaimsAndDisplays(#require(credentials["e5d7121f-683c-4775-8cf7-d415de4e339c"]), numberOfLanguages: 5, numberOfClaims: 17, numberOfIssuerDisplays: 5)
    try assertCredentialClaimsAndDisplays(
      #require(credentials["84912164-8775-4d14-bf7e-ff08a21b979f"]),
      numberOfLanguages: 2,
      numberOfClaims: 17,
      numberOfIssuerDisplays: 2,
      numberOfCredentialDisplays: 2,
      numberOfCredentialClaimDisplays: 4)
    if hasDeferredCredential {
      #expect(credentials["630c76ed-e712-4f1a-ae7e-6842ee5fa60a"]?.deferredCredential != nil)
    }
  }

  private func assertCredentialClaimsAndDisplays(
    _ credential: CredentialEntity,
    numberOfLanguages: Int,
    numberOfClaims: Int,
    numberOfIssuerDisplays: Int? = nil,
    numberOfCredentialDisplays: Int? = nil,
    numberOfCredentialClaimDisplays: Int? = nil) throws
  {
    #expect(credential.credentialRendering?.issuerDisplays.count == (numberOfIssuerDisplays ?? numberOfLanguages))
    #expect(credential.credentialRendering?.displays.count == (numberOfCredentialDisplays ?? numberOfLanguages))

    #expect(credential.credentialRendering?.clusters.count == 1)
    let cluster = try #require(credential.credentialRendering?.clusters.first)
    #expect(cluster.claims.count == numberOfClaims)
    for claim in cluster.claims {
      #expect(claim.displays.count == (numberOfCredentialClaimDisplays ?? numberOfLanguages))
      guard
        let data = claim.path.data(using: .utf8),
        let pointer = try? JSONSerialization.jsonObject(with: data) as? [String]
      else {
        Issue.record("not a valid claims path pointer string: \(claim.path)")
        continue
      }

      #expect(pointer.count == 1)
    }
  }

  private func assertRenderings(_ realm: Realm) {
    let credentials = realm.objects(CredentialEntity.self)
    #expect(credentials.count == 3)

    for credential in credentials {
      guard let rendering = credential.credentialRendering else {
        Issue.record("Missing credential rendering for \(credential.id)")
        continue
      }
      #expect(rendering.contentHash == contentHasher.hash(rendering))
    }

    #expect(realm.objects(CredentialRenderingEntity.self).count == 2)
  }

  private func assertNoOrphanedRenderingRows(_ realm: Realm) {
    let renderings = realm.objects(CredentialRenderingEntity.self)
    let clusters = renderings.flatMap { reachableClusters(Array($0.clusters)) }

    #expect(realm.objects(CredentialDisplayEntity.self).count == renderings.reduce(0) { $0 + $1.displays.count })
    #expect(realm.objects(CredentialIssuerDisplayEntity.self).count == renderings.reduce(0) { $0 + $1.issuerDisplays.count })
    #expect(realm.objects(CredentialClaimClusterEntity.self).count == clusters.count)
    #expect(realm.objects(CredentialClaimClusterDisplayEntity.self).count == clusters.reduce(0) { $0 + $1.displays.count })

    let claims = clusters.flatMap { Array($0.claims) }
    #expect(realm.objects(CredentialClaimEntity.self).count == claims.count)
    #expect(realm.objects(CredentialClaimDisplayEntity.self).count == claims.reduce(0) { $0 + $1.displays.count })
  }

  private func reachableClusters(_ clusters: [CredentialClaimClusterEntity]) -> [CredentialClaimClusterEntity] {
    clusters + clusters.flatMap { reachableClusters(Array($0.childClusters)) }
  }

  private func assertRawCredentialData(_ realm: Realm) {
    let rawCredentialDatas = realm.objects(RawCredentialDataEntity.self)
    #expect(rawCredentialDatas.count == 1)

    for rawCredentialData in rawCredentialDatas {
      #expect(rawCredentialData.contentHash == contentHasher.hash(rawCredentialData))
    }

    for credential in realm.objects(CredentialEntity.self) {
      #expect(credential.rawCredentialData?.contentHash == rawCredentialDatas.first?.contentHash)
    }
  }

  private func assertActivitySnapshots(_ realm: Realm, count: Int, claimsCount: Int? = nil) {
    let activities = realm.objects(CredentialActivityEntity.self)
    #expect(activities.count == count)

    for activity in activities {
      guard let credential = activity.credential.first else {
        Issue.record("Missing credential for activity \(activity.id)")
        continue
      }

      if let claimsCount {
        #expect(activity.claims.count == claimsCount)
      }
      #expect(activity.credentialRendering != nil)
      #expect(activity.credentialRendering?.contentHash == credential.credentialRendering?.contentHash)
      #expect(activity.rawCredentialData?.contentHash == credential.rawCredentialData?.contentHash)
      #expect(activity.issuer == credential.verifiableCredential?.issuer)
      if let bundleItem = activity.bundleItem {
        #expect(bundleItem.statusListState == presentableBundleItem(of: credential)?.status)
        #expect(bundleItem.payload == nil, "The presented token is not recoverable, and today's token is a different one")
      } else {
        #expect(presentableBundleItem(of: credential) == nil)
      }
    }
  }

  private func presentableBundleItem(of credential: CredentialEntity) -> BundleItemEntity? {
    guard let verifiableCredential = credential.verifiableCredential else { return nil }
    return verifiableCredential.bundleItems.first { $0.id == verifiableCredential.nextPresentableBundleItemId }
  }

  private func assertActivityClaims(_ realm: Realm, paths: [String]) {
    let presentedPaths = realm.objects(CredentialActivityEntity.self)
      .flatMap { $0.claims.map(\.path) }
      .sorted()

    #expect(presentedPaths == paths.sorted())
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

    #expect(summaries.contains("Categoria {{[\"categoryCode\"]}}"))
    #expect(summaries.contains("Catégorie {{[\"categoryCode\"]}}"))
    #expect(summaries.contains("Category {{[\"categoryCode\"]}}"))
    #expect(summaries.contains("Kategorie {{[\"categoryCode\"]}}"))
  }

  private func assertClaim(_ claims: Results<CredentialClaimEntity>, path: String, value: String) {
    #expect(
      claims.contains(where: { $0.path == path && $0.value == value }),
      "Missing claim with path \(path) and value \(value)")
  }

  private func assertClusters(_ realm: Realm) throws {
    let credentials: [CredentialEntity] = realm.objects(CredentialEntity.self).compactMap({ $0 })
    #expect(credentials.count == 3)

    for credential in credentials {
      #expect(credential.credentialRendering?.clusters.count == 1)
      let cluster = try #require(credential.credentialRendering?.clusters.first)
      #expect(cluster.childClusters.isEmpty)
      #expect(!cluster.claims.isEmpty)
    }
  }

  private func assertKeyBindings(_ realm: Realm) {
    let bindings: [CredentialKeyBindingEntity] = realm.objects(CredentialKeyBindingEntity.self).compactMap({ $0 })
    #expect(bindings.count == 3)
    for binding in bindings {
      assertKeyBinding(binding, algorithm: "ES256", bindingType: "hardware")
    }
  }

  private func assertVerifiableCredentials(_ realm: Realm, hasValidUntil: Bool) throws {
    let credentials: [CredentialEntity] = realm.objects(CredentialEntity.self).compactMap({ $0 })
    #expect(credentials.count == 3)

    for credential in credentials {
      guard let verifiableCredential = credential.verifiableCredential else {
        Issue.record("Missing verifiable credential for \(credential.id)")
        continue
      }

      #expect(
        verifiableCredential.bundleItems.contains(where: { $0.id == verifiableCredential.nextPresentableBundleItemId }),
        "Missing bundle item for nextPresentableBundleItemId on \(credential.id)")
    }

    try assertVerifiableCredential(
      #require(credentials["84912164-8775-4d14-bf7e-ff08a21b979f"]),
      issuer: "did:tdw:QmXteH1UtiERDjYSYd4xqG8QEBnwkqw7P9GHv6JQ9xqfNK:identifier-reg-r.trust-infra.swiyu.admin.ch:api:v1:did:b6aca1a5-8d71-4cfc-ad50-7f73314399b7",
      payloadCount: 584950,
      keyBindingId: "AFEED6F6-B3EC-41F6-B4EB-440BEB7BAD97",
      validFrom: Date(timeIntervalSinceReferenceDate: 732960000),
      validUntil: hasValidUntil ? Date(timeIntervalSinceReferenceDate: 851990400) : nil) // chasseral

    try assertVerifiableCredential(
      #require(credentials["82407f9a-5f47-40d7-a67b-2e59e311cada"]),
      issuer: "did:tdw:QmRhsT9rVEQWc2xqk19Lvgqo5qE5ufPqsujkbPSvZDNPUg:identifier-reg-a.trust-infra.swiyu-int.admin.ch:api:v1:did:3761f0a3-f7c1-44a0-bab9-aa7a4a4bc596",
      payloadCount: 170047,
      keyBindingId: "1C870514-85D5-4EF6-83CE-B2D4D2580833",
      validFrom: nil,
      validUntil: nil) // BCS

    try assertVerifiableCredential(
      #require(credentials["e5d7121f-683c-4775-8cf7-d415de4e339c"]),
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
    validUntil: Date? = nil) throws
  {
    #expect(credential.eIDRequestCase == nil)
    #expect(credential.deferredCredential == nil)
    let authentication = try #require(credential.authentication)
    guard let vc = credential.verifiableCredential else {
      Issue.record("No verifiable credential found for \(credential.id)")
      return
    }

    #expect(authentication.tokenType == "bearer")
    #expect(vc.progressionState == progressionState)
    #expect(vc.issuer == issuer)
    #expect(vc.bundleItems.count == 1)
    #expect(vc.bundleItems.first?.payload.count == payloadCount)
    #expect(vc.bundleItems.first?.status == status)
    #expect(vc.bundleItems.first?.presented == false)
    #expect(vc.bundleItems.first?.keyBinding?.id.uuidString == keyBindingId)
    #expect(vc.nextPresentableBundleItemId == vc.bundleItems.first?.id)
    #expect(vc.validFrom == validFrom)
    #expect(vc.validUntil == validUntil)
  }

  private func assertProgressionState(_ realm: Realm) {
    let credentials: [CredentialEntity] = realm.objects(CredentialEntity.self).compactMap({ $0 })
    for credential in credentials {
      if let vc = credential.verifiableCredential {
        #expect(vc.progressionState == .accepted)
      }
    }
  }

  private func assertBundleItemsAndDeferredKeyBindingsMigration(_ realm: Realm, hasDeferredCredential: Bool) throws {
    let credentials: [CredentialEntity] = realm.objects(CredentialEntity.self).compactMap({ $0 })

    let keyBindingIdsByCredentialId = [
      "82407f9a-5f47-40d7-a67b-2e59e311cada": "1C870514-85D5-4EF6-83CE-B2D4D2580833",
      "84912164-8775-4d14-bf7e-ff08a21b979f": "AFEED6F6-B3EC-41F6-B4EB-440BEB7BAD97",
      "e5d7121f-683c-4775-8cf7-d415de4e339c": "A0822BB1-B99F-45DF-BB56-DE1C8A96C00A",
    ]

    for (credentialId, keyBindingId) in keyBindingIdsByCredentialId {
      guard let credential = credentials[credentialId], let verifiableCredential = credential.verifiableCredential else {
        Issue.record("Missing verifiable credential with id \(credentialId)")
        continue
      }
      #expect(verifiableCredential.bundleItems.count == 1)
      #expect(verifiableCredential.bundleItems.first?.presented == false)
      #expect(verifiableCredential.nextPresentableBundleItemId == verifiableCredential.bundleItems.first?.id)
      assertKeyBinding(verifiableCredential.bundleItems.first?.keyBinding, id: keyBindingId, algorithm: "ES256", bindingType: "hardware")
    }

    guard hasDeferredCredential else {
      return
    }

    let deferredCredentialOwnerId = try #require(UUID(uuidString: "630c76ed-e712-4f1a-ae7e-6842ee5fa60a"), "Invalid deferred credential id")

    let credential = realm.object(ofType: CredentialEntity.self, forPrimaryKey: deferredCredentialOwnerId)
    guard let credential, let deferredCredential = credential.deferredCredential else {
      Issue.record("Missing deferred credential")
      return
    }

    #expect(deferredCredential.keyBindings.count == 1)
    assertKeyBinding(deferredCredential.keyBindings.first, algorithm: "ES256", bindingType: "software")

    let authentication = try #require(credential.authentication)
    #expect(authentication.accessToken == "dc7c4681-2fc4-454a-9d3f-0997926cf8d5")
    #expect(authentication.tokenType == "bearer")
    #expect(authentication.refreshToken == nil)
    #expect(authentication.dpopBinding == nil)
  }

  private func assertKeyBinding(_ keyBinding: CredentialKeyBindingEntity?, id: String? = nil, algorithm: String, bindingType: String) {
    guard let keyBinding else {
      Issue.record("Missing key binding")
      return
    }

    if let id {
      #expect(keyBinding.id.uuidString == id)
    }
    #expect(keyBinding.algorithm == algorithm)
    #expect(keyBinding.bindingType == bindingType)
    if bindingType == "hardware" {
      #expect(keyBinding.publicKey == nil)
      #expect(keyBinding.privateKey == nil)
    } else if bindingType == "software" {
      #expect(keyBinding.publicKey != nil)
      #expect(keyBinding.privateKey != nil)
      #expect(keyBinding.publicKey?.count == 65)
      #expect(keyBinding.privateKey?.count == 97)
    }
  }

  private func assertDeletionOfOrphanedObjects(_ realm: Realm, firstMissingDatabaseFeature: DatabaseFeature) {
    #expect(realm.objects(CredentialKeyBindingEntity.self).count == firstMissingDatabaseFeature.getKeyBindingCount())
    #expect(realm.objects(BundleItemEntity.self).count == 3)
    #expect(realm.objects(RawCredentialDataEntity.self).count == firstMissingDatabaseFeature.getRawCredentialDataCount())
    #expect(realm.objects(DPoPBindingEntity.self).isEmpty)
    #expect(realm.objects(DeferredCredentialEntity.self).count == firstMissingDatabaseFeature.getDeferredCredentialCount())
    #expect(realm.objects(BatchDataEntity.self).isEmpty)
    #expect(realm.objects(VerifiableCredentialEntity.self).count == 3)
    #expect(realm.objects(CredentialIssuerDisplayEntity.self).count == firstMissingDatabaseFeature.getCredentialIssuerDisplayCount())
    #expect(realm.objects(CredentialDisplayEntity.self).count == firstMissingDatabaseFeature.getCredentialDisplayCount())
    #expect(realm.objects(CredentialRenderingEntity.self).count == firstMissingDatabaseFeature.getCredentialRenderingCount())
    #expect(realm.objects(CredentialClaimClusterEntity.self).count == 3)
    #expect(realm.objects(CredentialClaimClusterDisplayEntity.self).count == firstMissingDatabaseFeature.getCredentialClaimClusterDisplayCount())
    #expect(realm.objects(CredentialClaimEntity.self).count == 57)
    #expect(realm.objects(CredentialClaimDisplayEntity.self).count == 268)
    #expect(realm.objects(EIDRequestStateEntity.self).isEmpty)
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
