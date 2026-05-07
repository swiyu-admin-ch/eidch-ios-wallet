import Factory
import NavigatorUI
import SwiftUI

// MARK: - ActivityDestinations

enum ActivityDestinations: NavigationDestination {
  case activities(credentialId: UUID)
  case activityDetail(activityId: UUID)
  case settings

  // MARK: Internal

  var method: NavigationMethod {
    switch self {
    case .activities,
         .activityDetail: .push
    case .settings:
      .managedSheet
    }
  }

  var body: some View {
    ActivityDestinationsView(destination: self)
  }
}

// MARK: - ActivityDestinationsView

private struct ActivityDestinationsView: View {
  let destination: ActivityDestinations
  @Injected(\.activityExternalViewProvider) var viewProvider
  var body: some View {
    switch destination {
    case .activities(let credentialId):
      ActivityListView(credentialId: credentialId)
    case .activityDetail(let activityId):
      viewProvider?.view(for: .activityDetail(activityId: activityId))
    case .settings:
      viewProvider?.view(for: .settings)
    }
  }
}
