// swiftlint: disable implicitly_unwrapped_optional force_unwrapping force_try
import Factory
import RealmSwift
import XCTest
@testable import BITActivity
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

  func testCallAsFunction_resolveDisplayWithMissingClaim_keepsPlaceholderEmpty() throws {
    let credential = try createCredential(claims: [], summary: "Value: {{[\"key\"]}}")

    let result = factory(credential, claimIds: [])

    XCTAssertEqual(result.displays.first?.summary, "Value: ")
  }

  func testCallAsFunction_resolveDisplayWithSingleClaim_returnsResolvedSummary() throws {
    let claim = try createClaim(path: "[\"key\"]", value: "value")
    let credential = try createCredential(claims: [claim], summary: "Value: {{[\"key\"]}}")

    let result = factory(credential, claimIds: [])

    XCTAssertEqual(result.displays.first?.summary, "Value: value")
  }

  func testCallAsFunction_resolveDisplayWithMultipleClaims_returnsResolvedSummary() throws {
    let claim1 = try createClaim(path: "[\"key1\"]", value: "value1")
    let claim2 = try createClaim(path: "[\"key2\"]", value: "value2")
    let credential = try createCredential(claims: [claim1, claim2], summary: "Value: {{[\"key1\"]}} {{[\"key2\"]}}")

    let result = factory(credential, claimIds: [])

    XCTAssertEqual(result.displays.first?.summary, "Value: value1 value2")
  }

  func testCallAsFunction_resolveDisplayWithNullClaim_returnsSummaryWithFallback() throws {
    let claim = try createClaim(path: "[\"key\"]", value: nil)
    let credential = try createCredential(claims: [claim], summary: "Value: {{[\"key\"]}}")

    let result = factory(credential, claimIds: [])

    XCTAssertEqual(result.displays.first?.summary, "Value: –")
  }

  func testResolveTemplate_withNoTemplate_returnsSummaryAsIs() throws {
    let credential = try createCredential(claims: [], summary: "summary")

    let result = factory(credential, claimIds: [])

    XCTAssertEqual(result.displays.first?.summary, "summary")
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

  private let nameMock = "issuer"
  private let localeMock = "locale"
  private let didMock = "did:tdw:mock:identifier-reg.trust-infra.swiyu.admin.ch:example"
  private var displayMock: CredentialDisplayEntity!
  private var otherDisplayMock: CredentialDisplayEntity!

  private var factory: ActivityDetailCredentialFactory!

  private func registerMocks() {
    Container.shared.configureInMemoryDataStore()
    Container.shared.preferredUserLanguageCodes.register { [self.localeMock] }

    displayMock = try! CredentialDisplayEntity.Mock.create(locale: "locale", createParent: false)
    otherDisplayMock = try! CredentialDisplayEntity.Mock.create(locale: "other", createParent: false)
  }

  private func createClaim(id: UUID = UUID(), path: String = "[\"key\"]", value: String? = nil) throws -> CredentialClaimEntity {
    try CredentialClaimEntity.Mock.create(id: id, path: path, value: value, createParent: false)
  }

  private func createCluster(claims: [CredentialClaimEntity] = [], childClusters: [CredentialClaimClusterEntity] = []) throws -> CredentialClaimClusterEntity {
    try CredentialClaimClusterEntity.Mock.create(claims: claims, childClusters: childClusters, createParent: false)
  }

  private func createCredential(claims: [CredentialClaimEntity], summary: String) throws -> CredentialEntity {
    let cluster = try createCluster(claims: claims)
    let verifiableCredential = try VerifiableCredentialEntity.Mock.create(clusters: [cluster], createParent: false)
    let display = try CredentialDisplayEntity.Mock.create(locale: localeMock, summary: summary, createParent: false)
    return try CredentialEntity.Mock.create(verifiableCredential: verifiableCredential, displays: [display])
  }
}
