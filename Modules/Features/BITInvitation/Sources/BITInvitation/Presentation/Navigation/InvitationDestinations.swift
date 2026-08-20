import BITCredential
import BITCredentialShared
import BITOpenID
import BITPresentation
import BITTheming
import NavigatorUI
import SwiftUI

public enum InvitationDestinations: NavigationDestination {
  case deeplink(URL)
  case external(InvitationExternalDestinations)
  case offer(VerifiableCredential)
  case actorInformation(ActorInformation)
  case scan(InvitationTab)
  case betaId
  case deeplinkError(ErrorDataset, Callback<Void>, PresentationResponse?)
  case error(ErrorDataset, Callback<Void>, PresentationResponse?)

  // MARK: Public

  public var method: NavigationMethod {
    switch self {
    case .actorInformation,
         .deeplink,
         .error:
      .managedSheet
    case .betaId,
         .deeplinkError,
         .external,
         .offer,
         .scan:
      .push
    }
  }

  public var body: some View {
    InvitationDestinationsView(destination: self)
  }
}
