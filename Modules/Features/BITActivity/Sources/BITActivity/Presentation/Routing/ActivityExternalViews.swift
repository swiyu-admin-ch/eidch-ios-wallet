import Foundation
import NavigatorUI

// MARK: - ActivityExternalViews

public enum ActivityExternalViews: NavigationViews {
  case activityDetail(activity: Activity, credentialId: UUID)
}
