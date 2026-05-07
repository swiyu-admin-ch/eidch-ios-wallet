import BITCredential
import BITCredentialShared
import BITPresentation
import BITTheming
import NavigatorUI
import SwiftUI

public enum InvitationDestinations: NavigationDestination {
  case deeplink(URL)
  case external(InvitationExternalDestinations)
  case offer(VerifiableCredential, TrustInformation?)
  case badgeInformation(BadgeType)
  case wrongData
  case scan(InvitationTab)
  case betaId
  case deeplinkError(ErrorDataset, Callback<Void>)
  case error(ErrorDataset, Callback<Void>)

  // MARK: Public

  public var method: NavigationMethod {
    switch self {
    case .badgeInformation,
         .deeplink,
         .error:
      .managedSheet
    case .betaId,
         .deeplinkError,
         .external,
         .offer,
         .scan,
         .wrongData:
      .push
    }
  }

  public var body: some View {
    InvitationDestinationsView(destination: self)
  }
}
