#if DEBUG
import Foundation
@testable import BITCore
@testable import BITTestingCore

extension Activity: Mockable {
  public struct Mock {
    public static let issueTrusted: Activity = decode(fromFile: "activity-issue-trusted", bundle: Bundle.module)
    public static let presentationAcceptedTrusted: Activity = decode(fromFile: "activity-presentation-accepted-trusted", bundle: Bundle.module)
    public static let presentationDeclinedUntrusted: Activity = decode(fromFile: "activity-presentation-declined-untrusted", bundle: Bundle.module)
  }
}
#endif
