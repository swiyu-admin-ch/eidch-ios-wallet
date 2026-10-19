import BITDataStore
import Factory
import FactoryTesting
import Foundation
import RealmSwift
import Testing
@testable import BITEntities

// MARK: - DatabaseCleanerTests

@MainActor
@Suite(.container)
struct DatabaseCleanerTests {

  // MARK: Lifecycle

  init() throws {
    Container.shared.configureInMemoryDataStore()
    realm = try Realm(configuration: Container.shared.realmDataStoreConfiguration())
  }

  // MARK: Internal

  enum RemainingImageUser: CaseIterable {
    case anotherCredential
    case activityActorDisplay
  }

  @Test
  func deleteOrphans_rowsStillOwnedAfterAnUnchangedUpdate_areKept() throws {
    let credential = makeCredential(rendering: makeRendering(contentHash: "unchanged", logoHash: Self.logoHash))
    try save(image: Self.logoHash)
    try save(credential: credential)
    try realm.write { credential.rawCredentialData = makeRawCredentialData(contentHash: "raw") }

    try cleaner.deleteOrphans(among: OrphanCandidates(credential))

    #expect(realm.object(ofType: CredentialRenderingEntity.self, forPrimaryKey: "unchanged") != nil)
    #expect(realm.object(ofType: RawCredentialDataEntity.self, forPrimaryKey: "raw") != nil)
    #expect(realm.object(ofType: ImageEntity.self, forPrimaryKey: Self.logoHash) != nil)
  }

  @Test
  func deleteOrphans_rowsReleasedByADeletedCredential_areRemoved() throws {
    let credential = makeCredential(rendering: makeRendering(contentHash: "released", logoHash: Self.logoHash))
    try save(image: Self.logoHash)
    try save(credential: credential)
    try realm.write { credential.rawCredentialData = makeRawCredentialData(contentHash: "raw") }

    let candidates = OrphanCandidates(credential)
    try realm.write { realm.delete(credential) }
    try cleaner.deleteOrphans(among: candidates)

    #expect(realm.object(ofType: CredentialRenderingEntity.self, forPrimaryKey: "released") == nil)
    #expect(realm.object(ofType: RawCredentialDataEntity.self, forPrimaryKey: "raw") == nil)
    #expect(realm.object(ofType: ImageEntity.self, forPrimaryKey: Self.logoHash) == nil)
  }

  @Test
  func deleteOrphans_renderingStillOnAnActivitySnapshot_isKept() throws {
    let shared = makeRendering(contentHash: "shared", logoHash: Self.logoHash)
    try save(image: Self.logoHash)
    let credential = makeCredential(rendering: shared)
    try save(credential: credential)

    let activity = CredentialActivityEntity()
    try realm.write {
      realm.add(activity)
      activity.credentialRendering = shared
    }

    let candidates = OrphanCandidates(credential)
    try realm.write { realm.delete(credential) }
    try cleaner.deleteOrphans(among: candidates)

    #expect(realm.object(ofType: CredentialRenderingEntity.self, forPrimaryKey: "shared") != nil)
    #expect(realm.object(ofType: ImageEntity.self, forPrimaryKey: Self.logoHash) != nil)
  }

  @Test(arguments: RemainingImageUser.allCases)
  func deleteOrphans_imageStillUsedElsewhere_isKept(user: RemainingImageUser) throws {
    try save(image: Self.logoHash)
    let credential = makeCredential(rendering: makeRendering(contentHash: "released", logoHash: Self.logoHash))
    try save(credential: credential)
    try store(user)

    let candidates = OrphanCandidates(credential)
    try realm.write { realm.delete(credential) }
    try cleaner.deleteOrphans(among: candidates)

    #expect(realm.object(ofType: CredentialRenderingEntity.self, forPrimaryKey: "released") == nil)
    #expect(realm.object(ofType: ImageEntity.self, forPrimaryKey: Self.logoHash) != nil)
  }

  @Test
  func deleteOrphans_snapshotRowsOfTheDeletedCredentialsActivities_areRemoved() throws {
    try save(image: Self.logoHash)
    try save(image: Self.snapshotLogoHash)
    let credential = makeCredential(rendering: makeRendering(contentHash: "current", logoHash: Self.logoHash))
    try save(credential: credential)

    let activity = CredentialActivityEntity()
    try realm.write {
      realm.add(activity)
      activity.credentialRendering = makeRendering(contentHash: "snapshot", logoHash: Self.snapshotLogoHash)
      credential.activities.append(activity)
    }

    let candidates = OrphanCandidates(credential)
    try dataStore.delete(credential)
    try cleaner.deleteOrphans(among: candidates)

    #expect(realm.object(ofType: CredentialRenderingEntity.self, forPrimaryKey: "current") == nil)
    #expect(realm.object(ofType: CredentialRenderingEntity.self, forPrimaryKey: "snapshot") == nil)
    #expect(realm.object(ofType: ImageEntity.self, forPrimaryKey: Self.logoHash) == nil)
    #expect(realm.object(ofType: ImageEntity.self, forPrimaryKey: Self.snapshotLogoHash) == nil)
  }

  @Test
  func deleteOrphans_unrelatedOrphan_isLeftForTheRepairPass() throws {
    let credential = makeCredential(rendering: makeRendering(contentHash: "released", logoHash: Self.logoHash))
    try save(image: Self.logoHash)
    try save(credential: credential)
    try realm.write { realm.add(makeRendering(contentHash: "unrelated", logoHash: Self.snapshotLogoHash)) }

    let candidates = OrphanCandidates(credential)
    try realm.write { realm.delete(credential) }
    try cleaner.deleteOrphans(among: candidates)

    #expect(realm.object(ofType: CredentialRenderingEntity.self, forPrimaryKey: "released") == nil)
    #expect(realm.object(ofType: CredentialRenderingEntity.self, forPrimaryKey: "unrelated") != nil)

    try cleaner.deleteAllOrphans()

    #expect(realm.object(ofType: CredentialRenderingEntity.self, forPrimaryKey: "unrelated") == nil)
  }

  // MARK: Private

  private static let logoHash = "logo-hash"
  private static let snapshotLogoHash = "snapshot-logo-hash"

  private let realm: Realm
  private let cleaner = Container.shared.databaseCleaner()
  private let dataStore = Container.shared.dataStore()

  private func store(_ user: RemainingImageUser) throws {
    switch user {
    case .anotherCredential:
      try save(credential: makeCredential(rendering: makeRendering(contentHash: "other", logoHash: Self.logoHash)))

    case .activityActorDisplay:
      let activity = CredentialActivityEntity()
      let actorDisplay = ActivityActorDisplayEntity()
      actorDisplay.imageHash = Self.logoHash
      activity.actorDisplays.append(actorDisplay)
      try realm.write { realm.add(activity) }
    }
  }

  private func makeRendering(contentHash: String, logoHash: String) -> CredentialRenderingEntity {
    let rendering = CredentialRenderingEntity()
    rendering.contentHash = contentHash
    let display = CredentialDisplayEntity()
    display.logoDataHash = logoHash
    rendering.displays.append(display)
    return rendering
  }

  private func makeRawCredentialData(contentHash: String) -> RawCredentialDataEntity {
    let rawCredentialData = RawCredentialDataEntity()
    rawCredentialData.contentHash = contentHash
    rawCredentialData.rawOcaBundle = Data(contentHash.utf8)
    return rawCredentialData
  }

  private func makeCredential(rendering: CredentialRenderingEntity) -> CredentialEntity {
    let credential = CredentialEntity()
    credential.credentialRendering = rendering
    return credential
  }

  private func save(image hash: String) throws {
    let image = ImageEntity()
    image.contentHash = hash
    image.image = Data("image".utf8)
    try realm.write { realm.add(image, update: .modified) }
  }

  private func save(credential: CredentialEntity) throws {
    try realm.write { realm.add(credential, update: .modified) }
  }
}
