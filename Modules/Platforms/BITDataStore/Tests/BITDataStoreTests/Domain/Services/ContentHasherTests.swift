import BITCore
import Foundation
import RealmSwift
import Testing
@testable import BITDataStore

// MARK: - RenderingSpec

/// The business content of a fixture rendering, so two of them can be compared without repeating the graph setup.
struct RenderingSpec: Sendable {
  var claimValue = "Alice"
  var extraClaimValues = [String]()
  var displayNames = ["First name"]
}

// MARK: - RenderingComparison

struct RenderingComparison: Sendable, CustomTestStringConvertible {

  static let all: [RenderingComparison] = [
    RenderingComparison(
      name: "equivalent graphs hash the same",
      first: RenderingSpec(),
      second: RenderingSpec(),
      hashesMatch: true),
    RenderingComparison(
      name: "a changed business value changes the hash",
      first: RenderingSpec(claimValue: "Alice"),
      second: RenderingSpec(claimValue: "Bob"),
      hashesMatch: false),
    RenderingComparison(
      name: "list order is ignored",
      first: RenderingSpec(extraClaimValues: ["b", "c"]),
      second: RenderingSpec(extraClaimValues: ["c", "b"]),
      hashesMatch: true),
    RenderingComparison(
      name: "a changed nested claim display changes the hash",
      first: RenderingSpec(displayNames: ["First name"]),
      second: RenderingSpec(displayNames: ["Given name"]),
      hashesMatch: false),
  ]

  let name: String
  let first: RenderingSpec
  let second: RenderingSpec
  let hashesMatch: Bool

  var testDescription: String {
    name
  }
}

// MARK: - RawPayloadPair

enum RawPayloadPair: CaseIterable {
  /// The very same bytes, once as stored and once compressed: the hasher must not interpret them.
  case storedAndCompressed
  /// Two payloads that only differ in their content.
  case differentContents
}

// MARK: - ContentHasherTests

@MainActor
struct ContentHasherTests {

  // MARK: Lifecycle

  init() throws {
    realm = try Realm(configuration: Self.configuration(inMemoryIdentifier: UUID().uuidString))
  }

  // MARK: Internal

  @Test(arguments: RenderingComparison.all)
  func hash_comparesTheBusinessContentOfTheGraph(comparison: RenderingComparison) throws {
    let first = try makeRendering(comparison.first)
    let second = try makeRendering(comparison.second)

    #expect((contentHasher.hash(first) == contentHasher.hash(second)) == comparison.hashesMatch)
  }

  @Test
  func hash_ignoresKeyAndBookkeepingColumns() throws {
    let first = try makeRendering(RenderingSpec())
    let second = try makeRendering(RenderingSpec())

    try realm.write { second.createdAt = first.createdAt.addingTimeInterval(3600) }

    #expect(first.id != second.id)
    #expect(first.createdAt != second.createdAt)
    #expect(contentHasher.hash(first) == contentHasher.hash(second))
  }

  @Test
  func hash_coversEveryPersistedPropertyWithoutBeingDeclared() throws {
    let rendering = try makeRendering(RenderingSpec())
    let before = contentHasher.hash(rendering)

    try realm.write { rendering.note = "changed" }

    #expect(before != contentHasher.hash(rendering))
  }

  /// The two displays hold the same content under claims that do not: a display is hashed by what
  /// it holds, never by what points at it.
  @Test
  func hash_ignoresBacklinks() throws {
    let alice = try makeRendering(RenderingSpec(claimValue: "Alice"))
    let bob = try makeRendering(RenderingSpec(claimValue: "Bob"))
    let aliceDisplay = try #require(alice.claims.first?.displays.first)
    let bobDisplay = try #require(bob.claims.first?.displays.first)

    #expect(!aliceDisplay.claim.isEmpty)
    #expect(contentHasher.hash(alice) != contentHasher.hash(bob))
    #expect(contentHasher.hash(aliceDisplay) == contentHasher.hash(bobDisplay))
  }

  @Test
  func hash_isIdenticalOnUnmanagedAndManagedObjects() throws {
    let rendering = Self.makeRendering(RenderingSpec(extraClaimValues: ["b"], displayNames: ["First name", "Prénom"]))
    let unmanagedHash = contentHasher.hash(rendering)

    try realm.write { realm.add(rendering) }

    #expect(unmanagedHash == contentHasher.hash(rendering))
  }

  @Test
  func hash_unmanagedGraphCoversItsChildren() {
    let withChildren = Self.makeRendering(RenderingSpec())
    let empty = HashFixtureRendering()
    empty.title = "title"

    #expect(contentHasher.hash(withChildren) != contentHasher.hash(empty))
  }

  @Test(arguments: RawPayloadPair.allCases)
  func hash_hashesStoredBytesWithoutInterpretingThem(pair: RawPayloadPair) throws {
    let (firstPayload, secondPayload) = try Self.payloads(for: pair)

    let first = HashFixtureRawCredentialData()
    first.rawOIDMetadata = firstPayload

    let second = HashFixtureRawCredentialData()
    second.rawOIDMetadata = secondPayload

    #expect(contentHasher.hash(first) != contentHasher.hash(second))
  }

  @Test
  func hash_terminatesOnACyclicGraph() throws {
    let first = HashFixtureCluster()
    let second = HashFixtureCluster()
    try realm.write {
      realm.add(first)
      realm.add(second)
      first.childClusters.append(second)
      second.childClusters.append(first)
    }

    #expect(!contentHasher.hash(first).isEmpty)
  }

  @Test
  func hash_doesNotTruncateDeepGraphs() throws {
    let shallow = try makeChain(depth: 40, leafPath: "leaf")
    let deep = try makeChain(depth: 40, leafPath: "different-leaf")

    #expect(contentHasher.hash(shallow) != contentHasher.hash(deep))
  }

  @Test
  func hash_isIdenticalOnTypedObjectsAndMigrationObjects() throws {
    let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).realm")
    defer { try? FileManager.default.removeItem(at: fileURL) }

    var configuration = Self.configuration()
    configuration.fileURL = fileURL
    configuration.schemaVersion = 1

    let typedHash: String = try autoreleasepool {
      let fileRealm = try Realm(configuration: configuration)
      let rendering = Self.makeRendering(RenderingSpec(extraClaimValues: ["b"], displayNames: ["First name", "Prénom"]))
      try fileRealm.write { fileRealm.add(rendering) }
      return contentHasher.hash(rendering)
    }

    let collector = HashCollector()
    let hasher = contentHasher
    let rootClass = Self.rootClass
    var migratedConfiguration = configuration
    migratedConfiguration.schemaVersion = 2
    migratedConfiguration.migrationBlock = { migration, _ in
      migration.enumerateObjects(ofType: rootClass) { oldObject, _ in
        guard let oldObject else { return }
        collector.hashes.append(hasher.hash(oldObject))
      }
    }

    _ = try autoreleasepool { try Realm(configuration: migratedConfiguration) }

    #expect(collector.hashes == [typedHash])
  }

  @Test
  func isContentHashed_followsThePrimaryKeyName() {
    #expect(!contentHasher.isContentHashed(HashFixtureRendering()))
    #expect(contentHasher.isContentHashed(HashFixtureContentHashed()))
  }

  // MARK: Private

  private static let rootClass = "HashFixtureRendering"
  private static let payload = Data(String(repeating: "{\"oca\":\"bundle\"}", count: 32).utf8)

  private let contentHasher: ContentHasherProtocol = ContentHasher()
  private let realm: Realm

  private static func payloads(for pair: RawPayloadPair) throws -> (Data, Data) {
    switch pair {
    case .storedAndCompressed:
      let compressed = try payload.compressed()
      return (payload, compressed)
    case .differentContents:
      return (Data("one payload".utf8), Data("another payload".utf8))
    }
  }

  private static func configuration(inMemoryIdentifier: String? = nil) -> Realm.Configuration {
    var configuration = Realm.Configuration()
    if let inMemoryIdentifier {
      configuration.inMemoryIdentifier = inMemoryIdentifier
    }
    configuration.objectTypes = [
      HashFixtureRendering.self,
      HashFixtureClaim.self,
      HashFixtureClaimDisplay.self,
      HashFixtureContentHashed.self,
      HashFixtureCluster.self,
    ]
    return configuration
  }

  private static func makeRendering(_ spec: RenderingSpec) -> HashFixtureRendering {
    let rendering = HashFixtureRendering()
    rendering.title = "title"
    rendering.claims.append(makeClaim(value: spec.claimValue, displayNames: spec.displayNames))
    for value in spec.extraClaimValues {
      rendering.claims.append(makeClaim(value: value, displayNames: spec.displayNames))
    }
    return rendering
  }

  private static func makeClaim(value: String, displayNames: [String]) -> HashFixtureClaim {
    let claim = HashFixtureClaim()
    claim.value = value
    claim.locale = .en
    claim.order = 1
    claim.isSensitive = true
    for name in displayNames {
      let display = HashFixtureClaimDisplay()
      display.locale = "en"
      display.name = name
      claim.displays.append(display)
    }
    return claim
  }

  private func makeChain(depth: Int, leafPath: String) throws -> HashFixtureCluster {
    let root = HashFixtureCluster()
    var tail = root
    for _ in 0..<depth {
      let child = HashFixtureCluster()
      tail.childClusters.append(child)
      tail = child
    }
    tail.path = leafPath
    try realm.write { realm.add(root) }
    return root
  }

  private func makeRendering(_ spec: RenderingSpec) throws -> HashFixtureRendering {
    let rendering = Self.makeRendering(spec)
    try realm.write { realm.add(rendering) }
    return rendering
  }
}

// MARK: - HashCollector

private final class HashCollector: @unchecked Sendable {
  var hashes = [String]()
}

// MARK: - HashFixtureLocale

enum HashFixtureLocale: String, PersistableEnum {
  case en
  case de
}

// MARK: - HashFixtureRendering

final class HashFixtureRendering: Object {
  @Persisted(primaryKey: true) var id: UUID
  @Persisted var createdAt = Date()
  @Persisted var title: String
  @Persisted var note: String?
  @Persisted var claims = List<HashFixtureClaim>()
}

// MARK: - HashFixtureClaim

final class HashFixtureClaim: Object {
  @Persisted(primaryKey: true) var id: UUID
  @Persisted var value: String
  @Persisted var locale: HashFixtureLocale?
  @Persisted var order: Int16
  @Persisted var isSensitive: Bool
  @Persisted var displays = List<HashFixtureClaimDisplay>()
}

// MARK: - HashFixtureClaimDisplay

final class HashFixtureClaimDisplay: Object {
  @Persisted(primaryKey: true) var id: UUID
  @Persisted var locale: String?
  @Persisted var name: String?
  @Persisted(originProperty: "displays") var claim: LinkingObjects<HashFixtureClaim>
}

// MARK: - HashFixtureContentHashed

final class HashFixtureContentHashed: Object {
  @Persisted(primaryKey: true) var contentHash: String
}

// MARK: - HashFixtureCluster

final class HashFixtureCluster: Object {
  @Persisted(primaryKey: true) var id: UUID
  @Persisted var path = "[]"
  @Persisted var childClusters = List<HashFixtureCluster>()
}

// MARK: - HashFixtureRawCredentialData

final class HashFixtureRawCredentialData: Object {
  @Persisted(primaryKey: true) var contentHash: String
  @Persisted var rawOIDMetadata: Data?
  @Persisted var rawOcaBundle: Data?
}
