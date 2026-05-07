import Foundation
import NavigatorUI

// MARK: - ActivityExternalViews

public enum ActivityExternalViews: NavigationViews {
  case activityDetail(activityId: UUID)
  case settings
}
