// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITActivity
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITOpenID
@testable import BITPresentation
@testable import BITTestingCore

final class ActivityPresentationTests: XCTestCase {

  // MARK: Internal

  func testInit_plainRequestObject_mapsDataCorrectly() throws {
    contextMock.requestObject.raw = Self.rawRequestObjectMock

    let activity = Activity(context: contextMock, credential: contextMock.selectedCredential!, type: .presentationAccepted)

    assertActivity(
      activity,
      type: .presentationAccepted,
      nonComplianceData: Self.rawRequestObjectMock,
      verifierDisplays: contextMock.verifierDisplays)
  }

  func testInit_jwtPresentationRequest_nonComplianceDataIsRawJWS() {
    let activity = Activity(context: jwtContextMock, credential: jwtContextMock.selectedCredential!, type: .presentationDeclined)

    assertActivity(
      activity,
      type: .presentationDeclined,
      nonComplianceData: "rawJWS".data(using: .utf8)!,
      verifierDisplays: jwtContextMock.verifierDisplays)
  }

  // MARK: Private

  private static let rawRequestObjectMock = "rawRequestObject".data(using: .utf8)!

  private let contextMock = PresentationRequestContext.Mock.vcSdJwtWithIdentityTrust
  private let jwtContextMock = PresentationRequestContext(presentationRequest: .jwt(JWTRequestObjectPayload.Mock.sample), compatibleCredentials: [CompatibleCredential.Mock.BIT], trustInformation: .Mock.trustedIdentity)

  private func assertActivity(_ activity: Activity, type: ActivityType, nonComplianceData: Data, verifierDisplays: [VerifierDisplay]) {
    XCTAssertEqual(activity.type, type)
    XCTAssertEqual(activity.actorTrust, .trusted)
    XCTAssertEqual(activity.vcSchemaTrust, .notProtected)
    XCTAssertEqual(activity.nonComplianceData, String(data: nonComplianceData, encoding: .utf8))

    XCTAssertEqual(activity.claims.count, 2)
    let claimIds = activity.claims.map(\.credentialClaimId.uuidString)
    XCTAssertTrue(claimIds.contains("416A2EC2-213B-438C-B9DA-47A2FF596A0C"))
    XCTAssertTrue(claimIds.contains("649E6F22-464A-4879-A301-266F78A06921"))

    XCTAssertEqual(activity.actorDisplays.count, verifierDisplays.count)
    for display in activity.actorDisplays {
      let verifierDisplay = verifierDisplays.first { $0.locale == display.locale }!
      XCTAssertEqual(display.name, verifierDisplay.name)
      XCTAssertEqual(display.image, verifierDisplay.logo)
    }
  }
}
