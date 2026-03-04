// swiftlint:disable force_unwrapping implicitly_unwrapped_optional
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

  func testResultInit() {
    let result = PresentationRequestReviewState.Result(credential: compatibleCredentialMock, verifierDisplay: verifierDisplayMock, colorScheme: colorSchemeMock)

    XCTAssertEqual(result.credential.credential, compatibleCredentialMock.credential)
    XCTAssertEqual(result.credential.colorScheme, colorSchemeMock)
    XCTAssertEqual(result.verifierDisplay, verifierDisplayMock)

    XCTAssertEqual(result.claimBadges.count, 2)
    XCTAssertEqual(result.claimBadges[0].name, "First name")
    XCTAssertEqual(result.claimBadges[0].isSensitive, false)
    XCTAssertEqual(result.claimBadges[1].name, "Last name")
    XCTAssertEqual(result.claimBadges[1].isSensitive, false)

    XCTAssertEqual(result.clusters, compatibleCredentialMock.requestedClaimClusters)
  }

  func testResultInit_sensitiveClaim_rightOrder() {
    let photoImage = PresentationField(jsonPath: "$.photoImage", value: CodableValue(value: "Test", as: "string"))
    let compatibleCredential = CompatibleCredential(credential: .Mock.sample, requestedFields: [CompatibleCredential.Mock.fieldFirstName, CompatibleCredential.Mock.fieldLastName, photoImage])

    let result = PresentationRequestReviewState.Result(credential: compatibleCredential, verifierDisplay: verifierDisplayMock, colorScheme: colorSchemeMock)

    XCTAssertEqual(result.claimBadges.count, 3)
    XCTAssertEqual(result.claimBadges[0].name, "Photo")
    XCTAssertEqual(result.claimBadges[0].isSensitive, true)
    XCTAssertEqual(result.claimBadges[1].name, "First name")
    XCTAssertEqual(result.claimBadges[1].isSensitive, false)
    XCTAssertEqual(result.claimBadges[2].name, "Last name")
    XCTAssertEqual(result.claimBadges[2].isSensitive, false)
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
