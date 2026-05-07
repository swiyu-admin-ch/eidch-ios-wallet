// swiftlint:disable force_unwrapping implicitly_unwrapped_optional
import Factory
import XCTest
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
    let claims = compatibleCredentialMock.requestedClaimClusters.flatMap(\.claims)

    XCTAssertEqual(result.credential.credential, compatibleCredentialMock.credential)
    XCTAssertEqual(result.credential.colorScheme, colorSchemeMock)
    XCTAssertEqual(result.verifierDisplay, verifierDisplayMock)

    XCTAssertEqual(result.claimBadges.count, 2)
    XCTAssertEqual(result.claimBadges[0].name, claims[0].preferredDisplay.name)
    XCTAssertEqual(result.claimBadges[0].isSensitive, false)
    XCTAssertEqual(result.claimBadges[1].name, claims[1].preferredDisplay.name)
    XCTAssertEqual(result.claimBadges[1].isSensitive, false)

    XCTAssertEqual(result.clusters, compatibleCredentialMock.requestedClaimClusters)
  }

  func testResultInit_sensitiveClaim_rightOrder() {
    let photoImage = PresentationField(jsonPath: "$.photoImage", value: CodableValue(value: "Test", as: "string"))
    let compatibleCredential = CompatibleCredential(credential: .Mock.sample, requestedFields: [CompatibleCredential.Mock.fieldFirstName, CompatibleCredential.Mock.fieldLastName, photoImage])

    let result = PresentationRequestReviewState.Result(credential: compatibleCredential, verifierDisplay: verifierDisplayMock, colorScheme: colorSchemeMock)
    let expectedBadges = compatibleCredential.requestedClaimClusters
      .flatMap(\.claims)
      .map { (name: $0.preferredDisplay.name, isSensitive: $0.isSensitive) }
      .sorted { $0.isSensitive && !$1.isSensitive }

    XCTAssertEqual(result.claimBadges.count, 3)
    XCTAssertEqual(result.claimBadges[0].name, expectedBadges[0].name)
    XCTAssertEqual(result.claimBadges[0].isSensitive, expectedBadges[0].isSensitive)
    XCTAssertEqual(result.claimBadges[1].name, expectedBadges[1].name)
    XCTAssertEqual(result.claimBadges[1].isSensitive, expectedBadges[1].isSensitive)
    XCTAssertEqual(result.claimBadges[2].name, expectedBadges[2].name)
    XCTAssertEqual(result.claimBadges[2].isSensitive, expectedBadges[2].isSensitive)
  }

  func testResultInit_noClaim_noClaimBadgesOrClusters() {
    let compatibleCredential = CompatibleCredential(credential: .Mock.sample, requestedFields: [])

    let result = PresentationRequestReviewState.Result(credential: compatibleCredential, verifierDisplay: verifierDisplayMock, colorScheme: colorSchemeMock)

    XCTAssertTrue(result.claimBadges.isEmpty)
    XCTAssertTrue(result.clusters.isEmpty)
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

}
