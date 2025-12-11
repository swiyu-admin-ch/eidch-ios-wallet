import BITActivity
import NavigatorUI
import SwiftUI

public enum ActivityDetailDestinations: NavigationDestination {
  case activityDetail(activity: Activity, credentialId: UUID)

  // MARK: Internal

  public var method: NavigationMethod {
    switch self {
    case .activityDetail: .push
    }
  }

  public var body: some View {
    switch self {
    case .activityDetail(let activity, let credentialId):
      ActivityDetailView(activity, credentialId: credentialId)
    }
  }
}
