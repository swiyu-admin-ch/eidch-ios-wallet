import BITCredentialShared
import BITOpenID
import Factory
import Foundation

@MainActor
extension Container {

  // MARK: - Credential offer

  var credentialOfferViewModel: ParameterFactory<(credential: Credential, trustStatement: TrustStatement?, state: CredentialOfferViewModel.State, router: CredentialOfferInternalRoutes), CredentialOfferViewModel> {
    self { CredentialOfferViewModel(credential: $0, trustStatement: $1, state: $2, router: $3) }
  }

  var credentialOfferModule: ParameterFactory<(Credential, TrustStatement?), CredentialOfferModule> {
    self { CredentialOfferModule(credential: $0, trustStatement: $1) }
  }

  var processPresentationRequestUseCase: Factory<ProcessPresentationRequestUseCaseProtocol> {
    self { ProcessPresentationRequestUseCase() }
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

  public var invitationRouter: Factory<InvitationRouter> {
    self { InvitationRouter() }
  }

  public var validateCredentialOfferInvitationUrlUseCase: Factory<ValidateCredentialOfferInvitationUrlUseCaseProtocol> {
    self { ValidateCredentialOfferInvitationUrlUseCase() }
  }

  public var checkInvitationTypeUseCase: Factory<CheckInvitationTypeUseCaseProtocol> {
    self { CheckInvitationTypeUseCase() }
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

  var getCredentialIssuerDisplayUseCase: Factory<GetCredentialIssuerDisplayUseCaseProtocol> {
    self { GetCredentialIssuerDisplayUseCase() }
  }

}
