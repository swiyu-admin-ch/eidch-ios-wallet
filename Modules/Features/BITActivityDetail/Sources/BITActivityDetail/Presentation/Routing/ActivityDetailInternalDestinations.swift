import BITCredential
import NavigatorUI
import SwiftUI

// MARK: - ActivityDetailInternalDestinations

enum ActivityDetailInternalDestinations: NavigationDestination {
  case actorInformation(ActorInformation)

  // MARK: Internal

  var method: NavigationMethod {
    .managedSheet
  }

  var body: some View {
    switch self {
    case .actorInformation(let actorInformation):
      ActorInformationView(actorInformation: actorInformation)
    }
  }
}
