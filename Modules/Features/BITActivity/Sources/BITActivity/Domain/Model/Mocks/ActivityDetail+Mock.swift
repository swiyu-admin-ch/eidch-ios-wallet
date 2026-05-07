#if DEBUG
import Foundation
@testable import BITCore

extension ActivityDetail: Mockable {
  public struct Mock {
    public static let trustedIssuance: ActivityDetail = decode(fromFile: "activity-detail-trusted-issuance", bundle: Bundle.module)
    public static let noCredentialDisplays: ActivityDetail = decode(fromFile: "activity-detail-no-credential-displays", bundle: Bundle.module)
  }
}
#endif
