// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import XCTest
@testable import BITActivity
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITTestingCore

final class ActivityIssuanceTests: XCTestCase {

  // MARK: Internal

  func testInit_mapsDataCorrectly() throws {
    let activity = Activity(credential: credentialMock, trustInformation: trustInformationMock, actorCompliance: .compliant)

    XCTAssertEqual(activity.type, .issuance)
    XCTAssertEqual(activity.actorTrust, .trusted)
    XCTAssertEqual(activity.vcSchemaTrust, .trusted)
    XCTAssertEqual(activity.nonComplianceData, nil)

    XCTAssertEqual(activity.actorDisplays.count, credentialMock.issuerDisplays.count)
    for display in activity.actorDisplays {
      let issuerDisplay = try XCTUnwrap(credentialMock.issuerDisplays.first { $0.locale == display.locale })
      XCTAssertEqual(display.name, issuerDisplay.name)
      XCTAssertEqual(display.image, issuerDisplay.image)
    }
  }

  // MARK: Private

  private let credentialMock = VerifiableCredential.Mock.sample
  private let trustInformationMock = TrustInformation.Mock.fullyTrusted
}
