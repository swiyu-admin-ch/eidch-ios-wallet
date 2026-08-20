#if DEBUG
import Foundation
@testable import BITCore

extension ActivityDetail: Mockable {
  public struct Mock {
    public static let trustedIssuance: ActivityDetail = decode(fromFile: "activity-detail-trusted-issuance", bundle: Bundle.module)
    public static let noCredentialDisplays: ActivityDetail = decode(fromFile: "activity-detail-no-credential-displays", bundle: Bundle.module)

    public static func make(
      actorTrust: ActorTrust,
      actorCompliance: ActorComplianceStatus = .compliant,
      nonComplianceReasonDisplay: NonComplianceReasonDisplay? = nil)
      -> ActivityDetail
    {
      ActivityDetail(
        id: UUID(),
        type: .issuance,
        createdAt: Date(),
        actorDisplay: nil,
        actorTrust: actorTrust,
        vcSchemaTrust: .trusted,
        actorCompliance: actorCompliance,
        nonComplianceReasonDisplay: nonComplianceReasonDisplay,
        credential: ActivityDetailCredential.Mock.default)
    }
  }
}
#endif
