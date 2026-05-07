#if DEBUG
import Foundation
@testable import BITActivity
@testable import BITCore
@testable import BITCredentialShared

extension NonComplianceExcessiveDataReport: Mockable {
  public struct Mock {
    public static let `default` = NonComplianceExcessiveDataReport(description: String(repeating: "x", count: 20), email: "admin@example.com", activity: .Mock.default)
  }
}
#endif
