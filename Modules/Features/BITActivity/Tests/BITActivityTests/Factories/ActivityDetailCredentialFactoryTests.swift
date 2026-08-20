// swiftlint: disable implicitly_unwrapped_optional force_unwrapping force_try
import Factory
import XCTest
@testable import BITActivity
@testable import BITClaimsPathPointer
@testable import BITEntities

final class ActivityDetailCredentialFactoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    factory = ActivityDetailCredentialFactory()
  }

  func testCallAsFunction_noClaimIdsAndNoDisplays_returnsCredentialWithoutClustersAndDisplays() throws {
    let verifiableCredential = try VerifiableCredentialEntity.Mock.create()
    let credential = try CredentialEntity.Mock.create(verifiableCredential: verifiableCredential)

    let result = factory(credential, claimIds: [])

    XCTAssertEqual(result.id, credential.id)
    XCTAssertEqual(result.displays.count, 0)
    XCTAssertEqual(result.environment, .external)
    XCTAssertEqual(result.clusters.count, 0)
  }

  func testCallAsFunction_displaysAvailable_returnsCredentialWithDisplays() throws {
    let displayMockEn = try CredentialDisplayEntity.Mock.create(locale: "locale", createParent: false)
    let verifiableCredential = try VerifiableCredentialEntity.Mock.create(createParent: false)
    let credential = try CredentialEntity.Mock.create(verifiableCredential: verifiableCredential, displays: [displayMock, otherDisplayMock, displayMockEn])

    let result = factory(credential, claimIds: [])

    XCTAssertEqual(result.displays.count, 2)
  }

  func testCallAsFunction_claimsAndDisplaysAvailable_returnsCredentialWithClusterAndDisplays() throws {
    let claimId = UUID()
    let cluster = try createCluster(claims: [createClaim(id: claimId)])
    let verifiableCredential = try VerifiableCredentialEntity.Mock.create(issuer: didMock, clusters: [cluster], createParent: false)
    let credential = try CredentialEntity.Mock.create(verifiableCredential: verifiableCredential, displays: [displayMock, otherDisplayMock])

    let result = factory(credential, claimIds: [claimId])

    XCTAssertEqual(result.id, credential.id)
    XCTAssertEqual(result.displays.count, 1)
    XCTAssertEqual(result.environment, .swiyu)
    XCTAssertEqual(result.clusters.count, 1)
    XCTAssertEqual(result.clusters.first?.claims.count, 1)
  }

  func testCallAsFunction_nestedClaims_returnsCredentialWithClusters() throws {
    let claimId1 = UUID()
    let claimId2 = UUID()
    let claimId3 = UUID()
    let childCluster = try createCluster(claims: [createClaim(), createClaim(id: claimId1)])
    let parentCluster = try createCluster(claims: [createClaim(), createClaim(id: claimId2)], childClusters: [childCluster, createCluster()])
    let cluster = try createCluster(claims: [createClaim(), createClaim(id: claimId3)])
    let verifiableCredential = try VerifiableCredentialEntity.Mock.create(issuer: didMock, clusters: [parentCluster, cluster], createParent: false)
    let credential = try CredentialEntity.Mock.create(verifiableCredential: verifiableCredential, displays: [displayMock, otherDisplayMock])

    let result = factory(credential, claimIds: [claimId1, claimId2, claimId3])

    XCTAssertEqual(result.clusters.count, 2)

    XCTAssertEqual(result.clusters[0].childClusters.count, 1)
    XCTAssertEqual(result.clusters[0].childClusters.first?.claims.count, 1)
    XCTAssertEqual(result.clusters[0].childClusters.first?.claims.first?.id, claimId1)

    XCTAssertEqual(result.clusters[0].claims.count, 1)
    XCTAssertEqual(result.clusters[0].claims.first?.id, claimId2)

    XCTAssertEqual(result.clusters[1].claims.count, 1)
    XCTAssertEqual(result.clusters[1].claims.first?.id, claimId3)
  }

  func testCallAsFunction_credentialDisplayWithClaimTemplate_returnsResolvedSummary() throws {
    let credential = try createCredential(claims: [claim], summary: "Value: {{\(Self.claimPath.stringValue)}}")

    let result = factory(credential, claimIds: [])

    XCTAssertEqual(result.displays.first?.summary, "Value: \(Self.value)")
  }

  func testCallAsFunction_clusterDisplayWithClaimTemplate_returnsResolvedName() throws {
    let cluster = try createCluster(claims: [claim], displays: [CredentialClaimClusterDisplayEntity.Mock.create(name: "Value: {{\(Self.claimPath.stringValue)}}", createParent: false)])
    let credential = try createCredential(clusters: [cluster])

    let result = factory(credential, claimIds: [Self.claimId])

    XCTAssertEqual(result.clusters.first?.displays.first?.name, "Value: \(Self.value)")
  }

  func testCallAsFunction_nestedClusterDisplayWithClaimTemplate_returnsResolvedName() throws {
    let nestedCluster = try createCluster(claims: [claim], displays: [CredentialClaimClusterDisplayEntity.Mock.create(name: "Value: {{\(Self.claimPath.stringValue)}}", createParent: false)])
    let cluster = try createCluster(childClusters: [nestedCluster])
    let credential = try createCredential(clusters: [cluster])

    let result = factory(credential, claimIds: [Self.claimId])

    XCTAssertEqual(result.clusters.first?.childClusters.first?.displays.first?.name, "Value: \(Self.value)")
  }

  func testCallAsFunction_indexedClusterDisplayWithClaimTemplate_returnsResolvedName() throws {
    let claimId = UUID()
    let claim1 = try createClaim(id: claimId, path: "[0, \"key\"]", value: "value1")
    let claim2 = try createClaim(path: "[1, \"key\"]", value: "value2")
    let cluster1 = try createCluster(path: [.index(0)], claims: [claim1], displays: [CredentialClaimClusterDisplayEntity.Mock.create(name: "Value: {{[null, \"key\"]}}", createParent: false)])
    let cluster2 = try createCluster(path: [.index(1)], claims: [claim2], displays: [])
    let credential = try createCredential(clusters: [cluster1, cluster2])

    let result = factory(credential, claimIds: [claimId])

    XCTAssertEqual(result.clusters.first?.displays.first?.name, "Value: value1")
  }

  func testCallAsFunction_noVerifiableCredential_returnsCredentialWithDisplays() throws {
    let credential = try CredentialEntity.Mock.create(displays: [displayMock])

    let result = factory(credential, claimIds: [])

    XCTAssertEqual(result.id, credential.id)
    XCTAssertEqual(result.displays.count, 1)
    XCTAssertEqual(result.environment, .external)
    XCTAssertEqual(result.clusters.count, 0)
  }

  // MARK: Private

  private static let claimId = UUID()
  private static let key = "key"
  private static let claimPath: ClaimsPathPointer = [.string(key)]
  private static let value = "value"

  private let nameMock = "issuer"
  private let localeMock = "locale"
  private let didMock = "did:tdw:mock:identifier-reg.trust-infra.swiyu.admin.ch:example"
  private var displayMock: CredentialDisplayEntity!
  private var otherDisplayMock: CredentialDisplayEntity!
  private var factory: ActivityDetailCredentialFactory!

  private var claim: CredentialClaimEntity {
    try! createClaim(id: Self.claimId, path: Self.claimPath.stringValue, value: Self.value)
  }

  private func registerMocks() {
    Container.shared.configureInMemoryDataStore()
    Container.shared.preferredUserLanguageCodes.register { [self.localeMock] }

    displayMock = try! CredentialDisplayEntity.Mock.create(locale: "locale", createParent: false)
    otherDisplayMock = try! CredentialDisplayEntity.Mock.create(locale: "other", createParent: false)
  }

  private func createClaim(id: UUID = claimId, path: String = claimPath.stringValue, value: String? = nil) throws -> CredentialClaimEntity {
    try CredentialClaimEntity.Mock.create(id: id, path: path, value: value, createParent: false)
  }

  private func createCluster(path: ClaimsPathPointer = [], claims: [CredentialClaimEntity] = [], childClusters: [CredentialClaimClusterEntity] = [], displays: [CredentialClaimClusterDisplayEntity] = []) throws -> CredentialClaimClusterEntity {
    try CredentialClaimClusterEntity.Mock.create(path: path.stringValue, claims: claims, childClusters: childClusters, displays: displays, createParent: false)
  }

  private func createCredential(clusters: [CredentialClaimClusterEntity], summary: String = "summary") throws -> CredentialEntity {
    let verifiableCredential = try VerifiableCredentialEntity.Mock.create(clusters: clusters, createParent: false)
    let display = try CredentialDisplayEntity.Mock.create(locale: localeMock, summary: summary, createParent: false)
    return try CredentialEntity.Mock.create(verifiableCredential: verifiableCredential, displays: [display])
  }

  private func createCredential(claims: [CredentialClaimEntity], summary: String = "summary") throws -> CredentialEntity {
    let cluster = try createCluster(claims: claims)
    return try createCredential(clusters: [cluster], summary: summary)
  }
}
