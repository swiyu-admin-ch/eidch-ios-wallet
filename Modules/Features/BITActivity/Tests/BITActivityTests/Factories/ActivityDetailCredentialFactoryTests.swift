import Factory
import FactoryTesting
import Foundation
import Testing
@testable import BITActivity
@testable import BITClaimsPathPointer
@testable import BITCredentialShared
@testable import BITEntities

// MARK: - ActivityDetailCredentialFactoryTests

@MainActor
@Suite(.container)
struct ActivityDetailCredentialFactoryTests {

  // MARK: Lifecycle

  init() throws {
    let localeMock = Self.localeMock
    Container.shared.configureInMemoryDataStore()
    Container.shared.preferredUserLanguageCodes.register { [localeMock] }

    displayMock = try CredentialDisplayEntity.Mock.create(locale: "locale", createParent: false)
    otherDisplayMock = try CredentialDisplayEntity.Mock.create(locale: "other", createParent: false)
    factory = ActivityDetailCredentialFactory()
  }

  // MARK: Internal

  @Test
  func callAsFunction_noPathsAndNoDisplays_returnsCredentialWithoutClustersAndDisplays() throws {
    let activity = try createActivity()

    let result = factory(activity, paths: [])

    #expect(result.id == activity.id)
    #expect(result.displays.isEmpty)
    #expect(result.environment == .external)
    #expect(result.clusters.isEmpty)
  }

  @Test
  func callAsFunction_displaysAvailable_returnsCredentialWithDisplays() throws {
    let displayMockEn = try CredentialDisplayEntity.Mock.create(locale: "locale", createParent: false)
    let activity = try createActivity(displays: [displayMock, otherDisplayMock, displayMockEn])

    let result = factory(activity, paths: [])

    #expect(result.displays.count == 2)
  }

  @Test
  func callAsFunction_claimsAndDisplaysAvailable_returnsCredentialWithClusterAndDisplays() throws {
    let cluster = try createCluster(claims: [createClaim(id: UUID())])
    let activity = try createActivity(displays: [displayMock, otherDisplayMock], clusters: [cluster], issuer: didMock)

    let result = factory(activity, paths: [Self.claimPath.stringValue])

    #expect(result.id == activity.id)
    #expect(result.displays.count == 1)
    #expect(result.environment == .swiyu)
    #expect(result.clusters.count == 1)
    #expect(result.clusters.first?.claims.count == 1)
  }

  @Test
  func callAsFunction_nestedClaims_returnsCredentialWithClusters() throws {
    let claimId1 = UUID()
    let claimId2 = UUID()
    let claimId3 = UUID()
    let childCluster = try createCluster(claims: [createClaim(), createClaim(id: claimId1, path: Self.firstPath)])
    let parentCluster = try createCluster(claims: [createClaim(), createClaim(id: claimId2, path: Self.secondPath)], childClusters: [childCluster, createCluster()])
    let cluster = try createCluster(claims: [createClaim(), createClaim(id: claimId3, path: Self.thirdPath)])
    let activity = try createActivity(displays: [displayMock, otherDisplayMock], clusters: [parentCluster, cluster], issuer: didMock)

    let result = factory(activity, paths: [Self.firstPath, Self.secondPath, Self.thirdPath])

    #expect(result.clusters.count == 2)

    #expect(result.clusters[0].childClusters.count == 1)
    #expect(result.clusters[0].childClusters.first?.claims.count == 1)
    #expect(result.clusters[0].childClusters.first?.claims.first?.id == claimId1)

    #expect(result.clusters[0].claims.count == 1)
    #expect(result.clusters[0].claims.first?.id == claimId2)

    #expect(result.clusters[1].claims.count == 1)
    #expect(result.clusters[1].claims.first?.id == claimId3)
  }

  @Test
  func callAsFunction_credentialDisplayWithClaimTemplate_returnsResolvedSummary() throws {
    let activity = try createActivity(claims: [claim()], summary: "Value: {{\(Self.claimPath.stringValue)}}")

    let result = factory(activity, paths: [])

    #expect(result.displays.first?.summary == "Value: \(Self.value)")
  }

  @Test
  func callAsFunction_clusterDisplayWithClaimTemplate_returnsResolvedName() throws {
    let cluster = try createCluster(claims: [claim()], displays: [CredentialClaimClusterDisplayEntity.Mock.create(name: "Value: {{\(Self.claimPath.stringValue)}}", createParent: false)])
    let activity = try createActivity(clusters: [cluster], summary: "summary")

    let result = factory(activity, paths: [Self.claimPath.stringValue])

    #expect(result.clusters.first?.displays.first?.name == "Value: \(Self.value)")
  }

  @Test
  func callAsFunction_nestedClusterDisplayWithClaimTemplate_returnsResolvedName() throws {
    let nestedCluster = try createCluster(claims: [claim()], displays: [CredentialClaimClusterDisplayEntity.Mock.create(name: "Value: {{\(Self.claimPath.stringValue)}}", createParent: false)])
    let cluster = try createCluster(childClusters: [nestedCluster])
    let activity = try createActivity(clusters: [cluster], summary: "summary")

    let result = factory(activity, paths: [Self.claimPath.stringValue])

    #expect(result.clusters.first?.childClusters.first?.displays.first?.name == "Value: \(Self.value)")
  }

  @Test
  func callAsFunction_indexedClusterDisplayWithClaimTemplate_returnsResolvedName() throws {
    let claim1 = try createClaim(id: UUID(), path: "[0, \"key\"]", value: "value1")
    let claim2 = try createClaim(id: UUID(), path: "[1, \"key\"]", value: "value2")
    let cluster1 = try createCluster(path: [.index(0)], claims: [claim1], displays: [CredentialClaimClusterDisplayEntity.Mock.create(name: "Value: {{[null, \"key\"]}}", createParent: false)])
    let cluster2 = try createCluster(path: [.index(1)], claims: [claim2], displays: [])
    let activity = try createActivity(clusters: [cluster1, cluster2], summary: "summary")

    let result = factory(activity, paths: ["[0, \"key\"]"])

    #expect(result.clusters.first?.displays.first?.name == "Value: value1")
  }

  @Test(arguments: [true, false])
  func callAsFunction_statusListState_comesFromTheBundleItemSnapshot(hasBundleItemSnapshot: Bool) throws {
    let activity: CredentialActivityEntity
    if hasBundleItemSnapshot {
      let bundleItem = ActivityBundleItemEntity()
      bundleItem.statusListState = .suspended
      activity = try CredentialActivityEntity.Mock.create(bundleItem: bundleItem, createParent: false)
    } else {
      activity = try createActivity()
    }

    let result = factory(activity, paths: [])

    let expected: CredentialStatus? = hasBundleItemSnapshot ? .suspended : nil
    #expect(result.statusListState == expected)
  }

  @Test
  func callAsFunction_noIssuer_returnsCredentialWithDisplays() throws {
    let activity = try createActivity(displays: [displayMock])

    let result = factory(activity, paths: [])

    #expect(result.id == activity.id)
    #expect(result.displays.count == 1)
    #expect(result.environment == .external)
    #expect(result.clusters.isEmpty)
  }

  // MARK: Private

  private static let claimId = UUID()
  private static let key = "key"
  private static let claimPath: ClaimsPathPointer = [.string(key)]
  private static let firstPath = "[\"first\"]"
  private static let secondPath = "[\"second\"]"
  private static let thirdPath = "[\"third\"]"
  private static let value = "value"
  private static let localeMock = "locale"

  private let didMock = "did:tdw:mock:identifier-reg.trust-infra.swiyu.admin.ch:example"
  private let displayMock: CredentialDisplayEntity
  private let otherDisplayMock: CredentialDisplayEntity
  private let factory: ActivityDetailCredentialFactory

  private func claim() throws -> CredentialClaimEntity {
    try createClaim(id: Self.claimId, path: Self.claimPath.stringValue, value: Self.value)
  }

  private func createClaim(id: UUID = claimId, path: String = claimPath.stringValue, value: String? = nil) throws -> CredentialClaimEntity {
    try CredentialClaimEntity.Mock.create(id: id, path: path, value: value, createParent: false)
  }

  private func createCluster(path: ClaimsPathPointer = [], claims: [CredentialClaimEntity] = [], childClusters: [CredentialClaimClusterEntity] = [], displays: [CredentialClaimClusterDisplayEntity] = []) throws -> CredentialClaimClusterEntity {
    try CredentialClaimClusterEntity.Mock.create(path: path.stringValue, claims: claims, childClusters: childClusters, displays: displays, createParent: false)
  }

  private func createActivity(
    displays: [CredentialDisplayEntity] = [],
    clusters: [CredentialClaimClusterEntity] = [],
    issuer: String = "") throws
    -> CredentialActivityEntity
  {
    let rendering = try CredentialRenderingEntity.Mock.create(displays: displays, clusters: clusters)
    return try CredentialActivityEntity.Mock.create(issuer: issuer, credentialRendering: rendering, createParent: false)
  }

  private func createActivity(clusters: [CredentialClaimClusterEntity], summary: String) throws -> CredentialActivityEntity {
    let display = try CredentialDisplayEntity.Mock.create(locale: Self.localeMock, summary: summary, createParent: false)
    return try createActivity(displays: [display], clusters: clusters)
  }

  private func createActivity(claims: [CredentialClaimEntity], summary: String) throws -> CredentialActivityEntity {
    let cluster = try createCluster(claims: claims)
    return try createActivity(clusters: [cluster], summary: summary)
  }
}
