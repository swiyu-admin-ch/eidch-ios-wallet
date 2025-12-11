import Factory
import NavigatorUI
import SwiftUI

// MARK: - ActivityDestinations

enum ActivityDestinations: NavigationDestination {
  case activities(credentialId: UUID)
  case activityDetail(activity: Activity, credentialId: UUID)

  // MARK: Internal

  var method: NavigationMethod {
    switch self {
    case .activities,
         .activityDetail: .push
    }
  }

  var body: some View {
    ActivityDestinationsView(destination: self)
  }
}

// MARK: - ActivityDestinationsView

private struct ActivityDestinationsView: View {
  let destination: ActivityDestinations
  @Injected(\.activityDetailViewProvider) var viewProvider
  var body: some View {
    switch destination {
    case .activities(let credentialId):
      ActivityListView(credentialId: credentialId)
    case .activityDetail(let activity, let credentialId):
      viewProvider?.view(for: .activityDetail(activity: activity, credentialId: credentialId))
    }
  }
}
