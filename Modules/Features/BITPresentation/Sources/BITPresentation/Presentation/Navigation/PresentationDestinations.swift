import BITCredential
import BITOpenID
import BITTheming
import NavigatorUI
import SwiftUI

public enum PresentationDestinations: NavigationDestination {
  case noCompatibleCredential(PresentationRequestContext)
  case compatibleCredentials(PresentationRequestContext)
  case requestReview(PresentationRequestContext)
  case actorInformation(ActorInformation)
  case claimInformation(isSensitive: Bool, claimName: String)
  case error(ErrorDataset, PresentationResponse?)
  case resultState(PresentationRequestResultState, PresentationRequestContext)
  case start(PresentationRequestContext)

  // MARK: Public

  public var method: NavigationMethod {
    switch self {
    case .compatibleCredentials,
         .error,
         .noCompatibleCredential,
         .requestReview,
         .resultState,
         .start:
      .push
    case .actorInformation,
         .claimInformation:
      .managedSheet
    }
  }

  public var body: some View {
    switch self {
    case .noCompatibleCredential(let context):
      NoCompatibleCredentialView(context: context)
    case .compatibleCredentials(let context):
      CompatibleCredentialView(context: context)
    case .requestReview(let context):
      PresentationRequestReviewView(context: context)
    case .actorInformation(let actorInformation):
      ActorInformationView(actorInformation: actorInformation)
    case .claimInformation(let isSensitive, let claimName):
      ClaimInformationView(isSensitive: isSensitive, claimName: claimName)
    case .error(let dataset, let presentationResponse):
      PresentationErrorView(dataset: dataset, presentationResponse: presentationResponse)
    case .resultState(let state, let context):
      PresentationRequestResultStateView(state: state, context: context)
    case .start(let context):
      if !context.hasVerifiedQuery {
        UnregisteredRequestView(context: context)
      } else if context.compatibleCredentials.isEmpty {
        NoCompatibleCredentialView(context: context)
      } else if context.compatibleCredentials.count > 1 {
        CompatibleCredentialView(context: context)
      } else {
        PresentationRequestReviewView(context: context)
      }
    }
  }
}
