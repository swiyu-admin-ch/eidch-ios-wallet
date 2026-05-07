#if DEBUG
import Foundation
@testable import BITCore

extension Activity: Mockable {
  public struct Mock {
    public static let `default`: Activity = decode(fromFile: "activity-default", bundle: Bundle.module)
  }
}
#endif
