import BITActivity
import NavigatorUI
import SwiftUI

public enum NonComplianceDestinations: NavigationDestination {
  case categories(activity: Activity)

  // MARK: Public

  public var method: NavigationMethod {
    .managedSheet
  }

  public var body: some View {
    switch self {
    case .categories(let activity):
      NonComplianceCategorySelectionView(activity: activity)
    }
  }
}
