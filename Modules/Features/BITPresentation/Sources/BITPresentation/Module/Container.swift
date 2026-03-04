import BITOpenID
import Factory

@MainActor
extension Container {

  var presentationRequestReviewViewModel: ParameterFactory<(PresentationRequestContext, PresentationInternalRoutes), PresentationRequestReviewViewModel> {
    self {
      PresentationRequestReviewViewModel(context: $0, router: $1)
    }
  }

  var compatibleCredentialViewModel: ParameterFactory<(context: PresentationRequestContext, router: PresentationInternalRoutes), CompatibleCredentialViewModel> {
    self { CompatibleCredentialViewModel(context: $0, router: $1) }
  }

  var presentationRequestResultStateViewModel: ParameterFactory<(state: PresentationRequestResultState, context: PresentationRequestContext, router: PresentationInternalRoutes), PresentationRequestResultStateViewModel> {
    self { PresentationRequestResultStateViewModel(state: $0, context: $1, router: $2) }
  }

  var declinePresentationUseCase: Factory<DeclinePresentationUseCaseProtocol> {
    self { DeclinePresentationUseCase() }
  }

  var submitPresentationUseCase: Factory<SubmitPresentationUseCaseProtocol> {
    self { SubmitPresentationUseCase() }
  }

  var declinePresentationViewModel: ParameterFactory<(PresentationRequestContext, PresentationInternalRoutes), DeclinePresentationViewModel> {
    self {
      DeclinePresentationViewModel(context: $0, router: $1)
    }
  }

}

extension Container {

  public var presentationRouter: Factory<PresentationRouter> {
    self { PresentationRouter() }.cached
  }

}

// MARK: - UseCase

extension Container {

  // MARK: Public

  public var getCompatibleCredentialsUseCase: Factory<GetCompatibleCredentialsUseCaseProtocol> {
    self { GetCompatibleCredentialsUseCase() }
  }

  public var dcqlCredentialMatcher: Factory<DcqlCredentialMatcherProtocol> {
    self { DcqlCredentialMatcher() }
  }

  public var authorizationResponseBodyGenerator: Factory<AuthorizationResponseBodyGeneratorProtocol> {
    self { AuthorizationResponseBodyGenerator() }
  }

  // MARK: Internal

  var loadingMessageDelay: Factory<Double> {
    self { 5 }
  }

  var declinePresentationRequestDelay: Factory<UInt64> {
    self { 1_000_000_000 }
  }
}
