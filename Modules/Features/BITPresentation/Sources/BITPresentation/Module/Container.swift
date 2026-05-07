import BITOpenID
import BITSwiyuSharedKMP
import Factory

@MainActor
extension Container {

  var presentationRequestReviewViewModel: ParameterFactory<PresentationRequestContext, PresentationRequestReviewViewModel> {
    self { @MainActor in
      PresentationRequestReviewViewModel(context: $0)
    }
  }

  var compatibleCredentialViewModel: ParameterFactory<PresentationRequestContext, CompatibleCredentialViewModel> {
    self { @MainActor in CompatibleCredentialViewModel(context: $0) }
  }

  var presentationRequestResultStateViewModel: ParameterFactory<(state: PresentationRequestResultState, context: PresentationRequestContext), PresentationRequestResultStateViewModel> {
    self { @MainActor in PresentationRequestResultStateViewModel(state: $0, context: $1) }
  }

  var declinePresentationUseCase: Factory<DeclinePresentationUseCaseProtocol> {
    self { @MainActor in DeclinePresentationUseCase() }
  }

  var submitPresentationUseCase: Factory<SubmitPresentationUseCaseProtocol> {
    self { @MainActor in SubmitPresentationUseCase() }
  }

  var declinePresentationViewModel: ParameterFactory<PresentationRequestContext, DeclinePresentationViewModel> {
    self { @MainActor in
      DeclinePresentationViewModel(context: $0)
    }
  }
}

// MARK: - UseCase

extension Container {

  // MARK: Public

  public var getCompatibleCredentialsUseCase: Factory<GetCompatibleCredentialsUseCaseProtocol> {
    self { @MainActor in GetCompatibleCredentialsUseCase() }
  }

  public var dcqlCredentialMatcher: Factory<DcqlCredentialMatcherProtocol> {
    self { @MainActor in DcqlCredentialMatcher() }
  }

  public var authorizationResponseBodyGenerator: Factory<AuthorizationResponseBodyGeneratorProtocol> {
    self { @MainActor in AuthorizationResponseBodyGenerator() }
  }

  public var proximityPresentationRepository: Factory<ProximityPresentationRepositoryProtocol> {
    self { @MainActor in ProximityPresentationRepository() }.cached
  }

  // MARK: Internal

  var proximityPresentationController: Factory<ProximityPresentationControllerProtocol> {
    self { @MainActor in
      HeidiProximity().initialize()
      return ProximityPresentationController()
    }
  }

  var loadingMessageDelay: Factory<Double> {
    self { @MainActor in 5 }
  }

  var declinePresentationRequestDelay: Factory<UInt64> {
    self { @MainActor in 1_000_000_000 }
  }
}
