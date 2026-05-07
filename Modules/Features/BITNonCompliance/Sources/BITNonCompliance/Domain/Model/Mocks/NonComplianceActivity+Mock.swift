#if DEBUG
import Foundation
@testable import BITCore

extension NonComplianceActivity: Mockable {
  public struct Mock {
    public static let `default` = NonComplianceActivity(nonComplianceData: "nonComplianceData", createdAt: Date(timeIntervalSinceReferenceDate: 0), issuer: "issuer")
  }
}
#endif
