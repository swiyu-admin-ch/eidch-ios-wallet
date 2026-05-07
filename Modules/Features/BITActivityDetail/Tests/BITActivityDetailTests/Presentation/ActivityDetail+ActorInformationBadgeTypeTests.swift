import XCTest
@testable import BITActivity
@testable import BITActivityDetail
@testable import BITCredential

final class ActivityActorInformationBadgeTypeTests: XCTestCase {

  // MARK: Internal

  func testActorInformationBadgeTypes_trusted() {
    let activity = makeActivity(actorTrust: .trusted, vcSchemaTrust: .trusted, actorCompliance: .compliant)

    XCTAssertEqual(activity.actorInformationBadgeTypes, [.trusted, .legitimateIssuer])
  }

  func testActorInformationBadgeTypes_untrusted() {
    let activity = makeActivity(actorTrust: .untrusted, vcSchemaTrust: .untrusted, actorCompliance: .compliant)

    XCTAssertEqual(activity.actorInformationBadgeTypes, [.notTrusted, .notLegitimateIssuer])
  }

  func testActorInformationBadgeTypes_unknownTrustNotProtectedSchema() {
    let activity = makeActivity(actorTrust: .unknown, vcSchemaTrust: .notProtected, actorCompliance: .compliant)

    XCTAssertEqual(activity.actorInformationBadgeTypes, [.unknownTrust])
  }

  func testActorInformationBadgeTypes_notCompliant() {
    let reason = "Reason EN"
    let activity = makeActivity(
      actorTrust: .trusted,
      vcSchemaTrust: .trusted,
      actorCompliance: .notCompliant,
      nonComplianceReasonDisplay: NonComplianceReasonDisplay(locale: "en", value: reason))

    XCTAssertEqual(activity.actorInformationBadgeTypes, [.trusted, .legitimateIssuer, .notCompliant(reason: reason)])
  }

  // MARK: Private

  private func makeActivity(
    actorTrust: ActorTrust,
    vcSchemaTrust: VcSchemaTrust,
    actorCompliance: ActorComplianceStatus,
    nonComplianceReasonDisplay: NonComplianceReasonDisplay? = nil)
    -> ActivityDetail
  {
    ActivityDetail(
      id: UUID(),
      type: .issuance,
      createdAt: Date(),
      actorDisplay: nil,
      actorTrust: actorTrust,
      vcSchemaTrust: vcSchemaTrust,
      actorCompliance: actorCompliance,
      nonComplianceReasonDisplay: nonComplianceReasonDisplay,
      credential: ActivityDetailCredential.Mock.default)
  }
}
