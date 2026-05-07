#if DEBUG
import Foundation
@testable import BITCore

extension ActivityListItem: Mockable {
  public struct Mock {
    public static let issuance: ActivityListItem = decode(fromFile: "activity-list-item-issuance", bundle: Bundle.module)
    public static let acceptedPresentation: ActivityListItem = decode(fromFile: "activity-list-item-accepted-presentation", bundle: Bundle.module)
    public static let declinedPresentation: ActivityListItem = decode(fromFile: "activity-list-item-declined-presentation", bundle: Bundle.module)
  }
}
#endif
