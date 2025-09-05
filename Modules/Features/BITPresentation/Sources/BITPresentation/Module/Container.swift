import BITOpenID
import Factory

@MainActor
extension Container {

  // MARK: Public

  public typealias PresentationCompletionHandler = () -> Void

  public var presentationRequestReviewViewModel: ParameterFactory<(PresentationRequestContext, PresentationRouterRoutes), PresentationRequestReviewViewModel> {
    self {
      PresentationRequestReviewViewModel(context: $0, router: $1)
    }
  }

  public var compatibleCredentialViewModel: ParameterFactory<(context: PresentationRequestContext, inputDescriptorId: String, compatibleCredentials: [CompatibleCredential], router: PresentationRouterRoutes), CompatibleCredentialViewModel> {
    self { CompatibleCredentialViewModel(context: $0, inputDescriptorId: $1, compatibleCredentials: $2, router: $3) }
  }

  // MARK: Internal

  var presentationRequestResultStateViewModel: ParameterFactory<(state: PresentationRequestResultState, context: PresentationRequestContext, router: PresentationRouterRoutes), PresentationRequestResultStateViewModel> {
    self { PresentationRequestResultStateViewModel(state: $0, context: $1, router: $2) }
  }

}

extension Container {

  public var presentationRouter: Factory<PresentationRouter> {
    self { PresentationRouter() }
  }

}

// MARK: - UseCase

extension Container {

  // MARK: Public

  public var submitPresentationUseCase: Factory<SubmitPresentationUseCaseProtocol> {
    self { SubmitPresentationUseCase() }
  }

  public var getCompatibleCredentialsUseCase: Factory<GetCompatibleCredentialsUseCaseProtocol> {
    self { GetCompatibleCredentialsUseCase() }
  }

  public var presentationRequestBodyGenerator: Factory<PresentationRequestBodyGeneratorProtocol> {
    self { PresentationRequestBodyGenerator() }
  }

  // MARK: Internal

  var loadingMessageDelay: Factory<Double> { self { 5 } }

  var getVerifierDisplayUseCase: Factory<GetVerifierDisplayUseCaseProtocol> {
    self { GetVerifierDisplayUseCase() }
  }
}
