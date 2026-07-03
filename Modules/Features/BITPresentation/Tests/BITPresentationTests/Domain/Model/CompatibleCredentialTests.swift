import Factory
import XCTest
@testable import BITClaimsPathPointer
@testable import BITCredentialShared
@testable import BITOpenID
@testable import BITPresentation
@testable import BITTestingCore

// MARK: - CompatibleCredentialTests

final class CompatibleCredentialTests: XCTestCase {

  // MARK: Internal

  func testRequestedClaimClusters_singleClusterAllClaims_returnsWholeCluster() {
    let paths = [
      Self.path1,
      Self.path2,
    ]
    let credential = CompatibleCredential(credential: VerifiableCredential.Mock.singleCluster, presentingPaths: paths)

    let result = credential.requestedClaimClusters

    XCTAssertEqual(result.count, 1)
    result.assertCluster(claimPaths: [Self.path1, Self.path2])
  }

  func testRequestedClaimClusters_singleClusterSomeClaims_returnsClusterPartly() {
    let paths = [Self.path2]
    let credential = CompatibleCredential(credential: VerifiableCredential.Mock.singleCluster, presentingPaths: paths)

    let result = credential.requestedClaimClusters

    XCTAssertEqual(result.count, 1)
    result.assertCluster(claimPaths: [Self.path2])
  }

  func testRequestedClaimClusters_multiClusterAllClaims_returnsAllClusters() {
    let paths = [
      Self.nestedPath11,
      Self.nestedPath12,
      Self.nestedPath21,
      Self.nestedPath22,
    ]
    let credential = CompatibleCredential(credential: VerifiableCredential.Mock.multiCluster, presentingPaths: paths)

    let result = credential.requestedClaimClusters

    result.assertMultiClusters(cluster1Paths: [Self.nestedPath11, Self.nestedPath12], cluster2Paths: [Self.nestedPath21, Self.nestedPath22])
  }

  func testRequestedClaimClusters_multiClusterAllClusters_returnsAllClusters() {
    let paths = [
      Self.path1,
      Self.path2,
    ]
    let credential = CompatibleCredential(credential: VerifiableCredential.Mock.multiCluster, presentingPaths: paths)

    let result = credential.requestedClaimClusters

    result.assertMultiClusters(cluster1Paths: [Self.nestedPath11, Self.nestedPath12], cluster2Paths: [Self.nestedPath21, Self.nestedPath22])
  }

  func testRequestedClaimClusters_multiClusterOneCluster_returnsOneCluster() {
    let paths = [Self.path2]
    let credential = CompatibleCredential(credential: VerifiableCredential.Mock.multiCluster, presentingPaths: paths)

    let result = credential.requestedClaimClusters

    result.assertMultiClusters(cluster2Paths: [Self.nestedPath21, Self.nestedPath22])
  }

  func testRequestedClaimClusters_multiClusterOneClaimBothClusters_returnsAllClustersPartly() {
    let paths = [
      Self.nestedPath11,
      Self.nestedPath22,
    ]
    let credential = CompatibleCredential(credential: VerifiableCredential.Mock.multiCluster, presentingPaths: paths)

    let result = credential.requestedClaimClusters

    result.assertMultiClusters(cluster1Paths: [Self.nestedPath11], cluster2Paths: [Self.nestedPath22])
  }

  func testRequestedClaimClusters_multiClusterOneClaim_returnsOneClusterOneClaim() {
    let paths = [Self.nestedPath21]
    let credential = CompatibleCredential(credential: VerifiableCredential.Mock.multiCluster, presentingPaths: paths)

    let result = credential.requestedClaimClusters

    result.assertMultiClusters(cluster2Paths: [Self.nestedPath21])
  }

  func testRequestedClaimClusters_nestedClusterAllClaims_returnsAllClusters() {
    let paths = [
      Self.nestedPath11,
      Self.nestedPath12,
      Self.nestedPath131,
      Self.nestedPath132,
    ]
    let credential = CompatibleCredential(credential: VerifiableCredential.Mock.nestedCluster, presentingPaths: paths)

    let result = credential.requestedClaimClusters

    result.assertNestedClusters(cluster1Paths: [Self.nestedPath11, Self.nestedPath12], cluster2Paths: [Self.nestedPath131, Self.nestedPath132])
  }

  func testRequestedClaimClusters_nestedClusterAllClusters_returnsAllClusters() {
    let paths = [
      Self.path1,
      Self.nestedPath13,
    ]
    let credential = CompatibleCredential(credential: VerifiableCredential.Mock.nestedCluster, presentingPaths: paths)

    let result = credential.requestedClaimClusters

    result.assertNestedClusters(cluster1Paths: [Self.nestedPath11, Self.nestedPath12], cluster2Paths: [Self.nestedPath131, Self.nestedPath132])
  }

  func testRequestedClaimClusters_nestedClusterRootCluster_returnsAllClusters() {
    let paths = [Self.path1]
    let credential = CompatibleCredential(credential: VerifiableCredential.Mock.nestedCluster, presentingPaths: paths)

    let result = credential.requestedClaimClusters

    result.assertNestedClusters(cluster1Paths: [Self.nestedPath11, Self.nestedPath12], cluster2Paths: [Self.nestedPath131, Self.nestedPath132])
  }

  func testRequestedClaimClusters_nestedClusterOneCluster_returnsOneCluster() {
    let paths = [Self.nestedPath13]
    let credential = CompatibleCredential(credential: VerifiableCredential.Mock.nestedCluster, presentingPaths: paths)

    let result = credential.requestedClaimClusters

    result.assertNestedClusters(cluster1Paths: [], cluster2Paths: [Self.nestedPath131, Self.nestedPath132])
  }

  func testRequestedClaimClusters_nestedClusterOneClaimBothClusters_returnsAllClustersPartly() {
    let paths = [
      Self.nestedPath11,
      Self.nestedPath132,
    ]
    let credential = CompatibleCredential(credential: VerifiableCredential.Mock.nestedCluster, presentingPaths: paths)

    let result = credential.requestedClaimClusters

    result.assertNestedClusters(cluster1Paths: [Self.nestedPath11], cluster2Paths: [Self.nestedPath132])
  }

  func testRequestedClaimClusters_nestedClusterOneClaimRoot_returnsOneClusterOneClaim() {
    let paths = [Self.nestedPath11]
    let credential = CompatibleCredential(credential: VerifiableCredential.Mock.nestedCluster, presentingPaths: paths)

    let result = credential.requestedClaimClusters
    result.assertNestedClusters(cluster1Paths: [Self.nestedPath11])
  }

  func testRequestedClaimClusters_nestedClusterOneClaimNested_returnsAllClustersOneClaim() {
    let paths = [Self.nestedPath131]
    let credential = CompatibleCredential(credential: VerifiableCredential.Mock.nestedCluster, presentingPaths: paths)

    let result = credential.requestedClaimClusters
    result.assertNestedClusters(cluster1Paths: [], cluster2Paths: [Self.nestedPath131])
  }

  // MARK: Private

  private static let path1: ClaimsPathPointer = [.string("path1")]
  private static let path2: ClaimsPathPointer = [.string("path2")]
  private static let nestedPath11: ClaimsPathPointer = [.string("path1"), .string("path1")]
  private static let nestedPath12: ClaimsPathPointer = [.string("path1"), .string("path2")]
  private static let nestedPath21: ClaimsPathPointer = [.string("path2"), .string("path1")]
  private static let nestedPath22: ClaimsPathPointer = [.string("path2"), .string("path2")]
  private static let nestedPath13: ClaimsPathPointer = [.string("path1"), .string("path3")]
  private static let nestedPath131: ClaimsPathPointer = [.string("path1"), .string("path3"), .string("path1")]
  private static let nestedPath132: ClaimsPathPointer = [.string("path1"), .string("path3"), .string("path2")]
}

extension [CredentialClaimCluster] {

  fileprivate func assertCluster(
    index: Int = 0,
    id: String = "b400b56d-dd63-40f8-b036-f0f788f57212",
    path: ClaimsPathPointer = [],
    order: Int = 0,
    isSensitive: Bool = true,
    displayId: String = "ab815150-cf66-4f66-8a50-a6a8cc10b871",
    childrenCount: Int = 0,
    claimPaths: [ClaimsPathPointer])
  {
    XCTAssertEqual(self[index].id, UUID(uuidString: id))
    XCTAssertEqual(self[index].path, path)
    XCTAssertEqual(self[index].order, order)
    XCTAssertEqual(self[index].isSensitive, isSensitive)
    XCTAssertEqual(self[index].displays[0].id, UUID(uuidString: displayId))
    XCTAssertEqual(self[index].childClusters.count, childrenCount)
    XCTAssertEqual(self[index].claims.count, claimPaths.count)
    for claimPath in claimPaths {
      XCTAssertTrue(self[index].claims.contains(where: { $0.path == claimPath }))
    }
  }

  fileprivate func assertMultiClusters(cluster1Paths: [ClaimsPathPointer]? = nil, cluster2Paths: [ClaimsPathPointer]? = nil) {
    var clusterCount = 0
    if let cluster1Paths {
      clusterCount += 1
      assertCluster(path: [.string("path1")], claimPaths: cluster1Paths)
    }

    if let cluster2Paths {
      clusterCount += 1
      let index = cluster1Paths != nil ? 1 : 0
      assertCluster(
        index: index,
        id: "0c5ee147-08df-43f8-89f7-01e41ca6d347",
        path: [.string("path2")],
        order: 1,
        isSensitive: false,
        displayId: "88f52b62-388a-4239-8fdc-212ba5641ae0",
        claimPaths: cluster2Paths)
    }

    XCTAssertEqual(count, clusterCount)
  }

  fileprivate func assertNestedClusters(cluster1Paths: [ClaimsPathPointer], cluster2Paths: [ClaimsPathPointer]? = nil) {
    XCTAssertEqual(count, 1)
    assertCluster(path: [.string("path1")], childrenCount: cluster2Paths != nil ? 1 : 0, claimPaths: cluster1Paths)

    if let cluster2Paths {
      self[0].childClusters.assertCluster(
        id: "0c5ee147-08df-43f8-89f7-01e41ca6d347",
        path: [.string("path1"), .string("path3")],
        order: 1,
        isSensitive: false,
        displayId: "88f52b62-388a-4239-8fdc-212ba5641ae0",
        claimPaths: cluster2Paths)
    }
  }
}
