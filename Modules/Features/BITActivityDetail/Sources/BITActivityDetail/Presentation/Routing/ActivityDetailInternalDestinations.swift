import BITCredential
import NavigatorUI
import SwiftUI

// MARK: - ActivityDetailInternalDestinations

enum ActivityDetailInternalDestinations: NavigationDestination {
  case badgeDetail(badgeType: BadgeType)

  // MARK: Internal

  var method: NavigationMethod {
    .managedSheet
  }

  var body: some View {
    switch self {
    case .badgeDetail(let badgeType):
      BadgeDetailDestinationView(badgeType: badgeType)
    }
  }
}

// MARK: - BadgeDetailDestinationView

private struct BadgeDetailDestinationView: View {
  let badgeType: BadgeType

  @Environment(\.navigator) private var navigator

  var body: some View {
    BadgeInformationView(badgeType: badgeType)
  }
}
