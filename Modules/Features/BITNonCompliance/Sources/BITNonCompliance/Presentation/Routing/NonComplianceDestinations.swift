import BITActivity
import NavigatorUI
import SwiftUI

public enum NonComplianceDestinations: NavigationDestination {
  case categories(activityType: ActivityType, activityId: UUID)

  // MARK: Public

  public var method: NavigationMethod {
    .managedSheet
  }

  public var body: some View {
    switch self {
    case .categories(let activityType, let activityId):
      NonComplianceCategorySelectionView(activityType: activityType, activityId: activityId)
    }
  }
}
