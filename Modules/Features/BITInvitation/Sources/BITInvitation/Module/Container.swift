import BITCredential
import BITCredentialShared
import Factory
import Foundation

@MainActor
extension Container {

  // MARK: - Credential offer

  var credentialOfferViewModel: ParameterFactory<(credential: VerifiableCredential, trustInformation: TrustInformation, state: CredentialOfferViewModel.State, router: CredentialOfferInternalRoutes), CredentialOfferViewModel> {
    self { CredentialOfferViewModel(credential: $0, trustInformation: $1, state: $2, router: $3) }
  }

  var credentialOfferModule: ParameterFactory<(VerifiableCredential, TrustInformation), CredentialOfferModule> {
    self { CredentialOfferModule(credential: $0, trustInformation: $1) }
  }

  // MARK: - Camera

  var cameraPermissionViewModel: ParameterFactory<InvitationRouterRoutes, CameraPermissionViewModel> {
    self { CameraPermissionViewModel(router: $0) }
  }

  var cameraViewModel: ParameterFactory<InvitationRouterRoutes, CameraViewModel> {
    self { CameraViewModel(router: $0) }
  }

  var deeplinkViewModel: ParameterFactory<(URL, InvitationRouterRoutes), DeeplinkViewModel> {
    self { DeeplinkViewModel(url: $0, router: $1) }
  }

  // MARK: - Beta ID

  var betaIdViewModel: ParameterFactory<InvitationRouterRoutes, BetaIdViewModel> {
    self { BetaIdViewModel(router: $0) }
  }

}

extension Container {

  // MARK: Public

  public var fetchPresentationRequestUseCase: Factory<FetchPresentationRequestUseCaseProtocol> {
    self { FetchPresentationRequestUseCase() }
  }

  public var invitationRouter: Factory<InvitationRouter> {
    self { InvitationRouter() }
  }

  public var delayAfterAcceptingCredential: Factory<UInt64> {
    self { 2_000_000_000 }
  }

  // MARK: Internal

  var credentialOfferWrongDataViewModel: ParameterFactory<CredentialOfferInternalRoutes, CredentialOfferWrongDataViewModel> {
    self { CredentialOfferWrongDataViewModel(router: $0) }
  }

  var credentialOfferRouter: Factory<CredentialOfferRouter> {
    self { CredentialOfferRouter() }
  }

  var scannerDelay: Factory<UInt64> {
    self { 2_000_000_000 }
  }

  var getCredentialsCountUseCase: Factory<GetCredentialsCountUseCaseProtocol> {
    self { GetCredentialsCountUseCase() }
  }
}
