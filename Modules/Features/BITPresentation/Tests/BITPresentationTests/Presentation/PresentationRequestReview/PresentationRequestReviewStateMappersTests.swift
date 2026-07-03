// swiftlint:disable force_unwrapping implicitly_unwrapped_optional
import Factory
import XCTest
@testable import BITClaimsPathPointer
@testable import BITCore
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITOpenID
@testable import BITPresentation
@testable import BITTestingCore

@MainActor
class PresentationRequestReviewStateMappersTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    Container.shared.preferredUserLanguageCodes.register { ["en"] }
  }

  func testResultInit() {
    let result = PresentationRequestReviewState.Result(credential: compatibleCredentialMock, verifierDisplay: verifierDisplayMock, colorScheme: colorSchemeMock)

    XCTAssertEqual(result.credential.credential, compatibleCredentialMock.credential)
    XCTAssertEqual(result.credential.colorScheme, colorSchemeMock)
    XCTAssertEqual(result.verifierDisplay, verifierDisplayMock)

    XCTAssertEqual(result.claimBadges.count, 2)
    XCTAssertEqual(result.claimBadges[0].name, lastName)
    XCTAssertEqual(result.claimBadges[0].isSensitive, false)
    XCTAssertEqual(result.claimBadges[1].name, firstName)
    XCTAssertEqual(result.claimBadges[1].isSensitive, false)

    XCTAssertEqual(result.clusters, compatibleCredentialMock.requestedClaimClusters)
  }

  func testResultInit_sensitiveClaim_rightOrder() {
    let photoImage: ClaimsPathPointer = [.string("photoImage")]
    let compatibleCredential = CompatibleCredential(credential: .Mock.sample, presentingPaths: [CompatibleCredential.Mock.pathFirstName, CompatibleCredential.Mock.pathLastName, photoImage])

    let result = PresentationRequestReviewState.Result(credential: compatibleCredential, verifierDisplay: verifierDisplayMock, colorScheme: colorSchemeMock)
    let expectedBadges = compatibleCredential.requestedClaimClusters
      .flatMap(\.claims)
      .map { (name: $0.preferredDisplay.name, isSensitive: $0.isSensitive) }
      .sorted { $0.isSensitive && !$1.isSensitive }

    XCTAssertEqual(result.claimBadges.count, 3)
    XCTAssertEqual(result.claimBadges[0].name, "Photo")
    XCTAssertEqual(result.claimBadges[0].isSensitive, expectedBadges[0].isSensitive)
    XCTAssertEqual(result.claimBadges[1].name, lastName)
    XCTAssertEqual(result.claimBadges[1].isSensitive, expectedBadges[1].isSensitive)
    XCTAssertEqual(result.claimBadges[2].name, firstName)
    XCTAssertEqual(result.claimBadges[2].isSensitive, expectedBadges[2].isSensitive)
  }

  func testResultInit_noClaim_noClaimBadgesOrClusters() {
    let compatibleCredential = CompatibleCredential(credential: .Mock.sample, presentingPaths: [])

    let result = PresentationRequestReviewState.Result(credential: compatibleCredential, verifierDisplay: verifierDisplayMock, colorScheme: colorSchemeMock)

    XCTAssertTrue(result.claimBadges.isEmpty)
    XCTAssertTrue(result.clusters.isEmpty)
  }

  func testResultInit_arraysWithDuplicateClaimBadge_rightOrderAndUniqueBadges() {
    let compatibleCredential = CompatibleCredential(credential: .Mock.multiCluster, presentingPaths: [path1, path2])

    let result = PresentationRequestReviewState.Result(credential: compatibleCredential, verifierDisplay: verifierDisplayMock, colorScheme: colorSchemeMock)

    XCTAssertEqual(result.claimBadges.count, 3)
    XCTAssertEqual(result.claimBadges[0].name, claimName2)
    XCTAssertEqual(result.claimBadges[0].isSensitive, true)
    XCTAssertEqual(result.claimBadges[1].name, claimName1)
    XCTAssertEqual(result.claimBadges[1].isSensitive, false)
    XCTAssertEqual(result.claimBadges[2].name, claimName2)
    XCTAssertEqual(result.claimBadges[2].isSensitive, false)
  }

  func testResultInit_nestedWithDuplicates_rightOrderAndUniqueBadges() {
    let compatibleCredential = CompatibleCredential(credential: .Mock.nestedCluster, presentingPaths: [path1, path2])

    let result = PresentationRequestReviewState.Result(credential: compatibleCredential, verifierDisplay: verifierDisplayMock, colorScheme: colorSchemeMock)

    XCTAssertEqual(result.claimBadges.count, 3)
    XCTAssertEqual(result.claimBadges[0].name, "Third claim")
    XCTAssertEqual(result.claimBadges[0].isSensitive, true)
    XCTAssertEqual(result.claimBadges[1].name, claimName2)
    XCTAssertEqual(result.claimBadges[1].isSensitive, true)
    XCTAssertEqual(result.claimBadges[2].name, claimName1)
    XCTAssertEqual(result.claimBadges[2].isSensitive, false)
  }

  func testResultInit_simpleTypedArray_oneBadge() {
    let compatibleCredential = CompatibleCredential(credential: .Mock.simpleTypedCluster, presentingPaths: [path1])

    let result = PresentationRequestReviewState.Result(credential: compatibleCredential, verifierDisplay: verifierDisplayMock, colorScheme: colorSchemeMock)

    XCTAssertEqual(result.claimBadges.count, 1)
    XCTAssertEqual(result.claimBadges[0].name, "First cluster")
    XCTAssertEqual(result.claimBadges[0].isSensitive, true)
  }

  func testProcessingInit() {
    let result = PresentationRequestReviewState.Result(credential: compatibleCredentialMock, verifierDisplay: verifierDisplayMock, colorScheme: colorSchemeMock)

    let processing = PresentationRequestReviewState.Processing(result: result)

    XCTAssertEqual(processing.credential, result.credential)
    XCTAssertEqual(processing.verifierDisplay, result.verifierDisplay)
    XCTAssertEqual(processing.isMessagePresented, false)
  }

  // MARK: Private

  private let compatibleCredentialMock = CompatibleCredential.Mock.BIT
  private let verifierDisplayMock = VerifierDisplay.Mock.sample
  private let colorSchemeMock = "colorScheme"
  private let claimName1 = "First claim"
  private let claimName2 = "Second claim"
  private let firstName = "First name"
  private let lastName = "Last name"
  private let path1: ClaimsPathPointer = [.string("path1")]
  private let path2: ClaimsPathPointer = [.string("path2")]

}
