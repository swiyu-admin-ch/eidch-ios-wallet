import BITCredential
import BITTheming
import Factory
import SwiftUI

struct InvitationDestinationsView: View {

  // MARK: Lifecycle

  init(destination: InvitationDestinations) {
    self.destination = destination
  }

  // MARK: Internal

  var body: some View {
    switch destination {
    case .deeplink(let url):
      DeeplinkLoadingView(url: url)
    case .deeplinkError(let dataset, let onClose, let presentationResponse):
      InvitationErrorView(
        dataset: dataset,
        presentationResponse: presentationResponse,
        onClose: { onClose(Void()) })
    case .error(let dataset, let onClose, let presentationResponse):
      InvitationErrorView(
        dataset: dataset,
        presentationResponse: presentationResponse,
        onClose: { onClose(Void()) })
    case .external(let externalDestination):
      invitationExternalViewProvider?.view(for: externalDestination)
    case .offer(let credential):
      CredentialOfferView(credential: credential)
    case .actorInformation(let actorInformation):
      ActorInformationView(actorInformation: actorInformation)
    case .scan(let tab):
      InvitationContainerView(tab: tab)
    case .betaId:
      BetaIdView()
    }
  }

  // MARK: Private

  @Injected(\.invitationExternalViewProvider) private var invitationExternalViewProvider

  private let destination: InvitationDestinations
}
