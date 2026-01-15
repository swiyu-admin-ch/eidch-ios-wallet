#if DEBUG
import Foundation
@testable import BITActivity
@testable import BITCore
@testable import BITCredentialShared
@testable import BITTestingCore

extension NonComplianceExcessiveDataReport: Mockable {
  public struct Mock {
    public static let `default` = NonComplianceExcessiveDataReport(description: String(repeating: "x", count: 20), email: "admin@example.com", activity: Activity.Mock.presentationAcceptedTrusted, credential: VerifiableCredential.Mock.sample)
  }
}
#endif
