import Foundation
import Testing
@testable import BITActivity
@testable import BITActivityDetail
@testable import BITCredential

struct ActivityActorHeaderViewModelTests {

  @Test
  func actorHeaderViewModel_trustedShowsTrustBadge() {
    let activity = ActivityDetail.Mock.make(actorTrust: .trusted)

    #expect(activity.actorHeaderViewModel.showsTrustBadge)
  }

  @Test
  func actorHeaderViewModel_untrustedDoesNotShowTrustBadge() {
    let activity = ActivityDetail.Mock.make(actorTrust: .untrusted)

    #expect(!activity.actorHeaderViewModel.showsTrustBadge)
  }

  @Test
  func actorHeaderViewModel_unknownDoesNotShowTrustBadge() {
    let activity = ActivityDetail.Mock.make(actorTrust: .unknown)

    #expect(!activity.actorHeaderViewModel.showsTrustBadge)
  }

  @Test
  func actorHeaderViewModel_notCompliant() {
    let reason = "Reported actor reason"
    let activity = ActivityDetail.Mock.make(
      actorTrust: .trusted,
      actorCompliance: .notCompliant,
      nonComplianceReasonDisplay: NonComplianceReasonDisplay(locale: nil, value: reason))

    #expect(activity.actorHeaderViewModel.isNonCompliant)
    #expect(activity.actorHeaderViewModel.actorInformation.nonComplianceReason == nil)
    #expect(activity.actorHeaderViewModel.nonComplianceActorInformation.nonComplianceReason == reason)
  }
}
