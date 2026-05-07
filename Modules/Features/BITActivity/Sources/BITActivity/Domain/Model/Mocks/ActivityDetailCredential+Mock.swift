#if DEBUG
import Foundation
@testable import BITCore

extension ActivityDetailCredential: Mockable {
  public struct Mock {
    public static let `default`: ActivityDetailCredential = decode(fromFile: "activity-detail-credential", bundle: Bundle.module)
  }
}
#endif
