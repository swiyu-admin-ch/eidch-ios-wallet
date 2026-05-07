import BITCredential
import BITCredentialShared
import BITPresentation
import Factory
import Foundation
import NavigatorUI

@MainActor
extension Container {
  // MARK: - Credential offer

  var credentialOfferViewModel: ParameterFactory<(credential: VerifiableCredential, trustInformation: TrustInformation?, state: CredentialOfferViewModel.State), CredentialOfferViewModel> {
    self { @MainActor in CredentialOfferViewModel(credential: $0, trustInformation: $1, state: $2) }
  }

  // MARK: - Camera

  var cameraViewModel: Factory<CameraViewModel> {
    self { @MainActor in CameraViewModel() }
  }

  var deeplinkViewModel: ParameterFactory<URL, DeeplinkViewModel> {
    self { @MainActor in DeeplinkViewModel(url: $0) }
  }

  var proximityEngagementViewModel: Factory<ProximityEngagementViewModel> {
    self { @MainActor in ProximityEngagementViewModel() }
  }
}

extension Container {

  // MARK: Public

  public var fetchPresentationRequestUseCase: Factory<FetchPresentationRequestUseCaseProtocol> {
    self { @MainActor in FetchPresentationRequestUseCase() }
  }

  public var invitationErrorMapper: Factory<InvitationErrorMapping> {
    self { @MainActor in InvitationErrorMapper() }
  }

  public var invitationRouter: Factory<InvitationRouter> {
    self { @MainActor in InvitationRouter() }
  }

  public var startProximityEngagementUseCase: Factory<StartProximityEngagementUseCaseProtocol> {
    self { @MainActor in StartProximityEngagementUseCase() }
  }

  public var delayAfterAcceptingCredential: Factory<UInt64> {
    self { @MainActor in 2_000_000_000 }
  }

  public var invitationExternalViewProvider: Factory<(any NavigationViewProviding<InvitationExternalDestinations>)?> {
    self { @MainActor in nil }
  }

  // MARK: Internal

  var requestBluetoothPermissionUseCase: Factory<RequestBluetoothPermissionUseCaseProtocol> {
    self { @MainActor in RequestBluetoothPermissionUseCase() }
  }

  var scannerDelay: Factory<UInt64> {
    self { @MainActor in 2_000_000_000 }
  }

  var getCredentialsCountUseCase: Factory<GetCredentialsCountUseCaseProtocol> {
    self { @MainActor in GetCredentialsCountUseCase() }
  }
}
