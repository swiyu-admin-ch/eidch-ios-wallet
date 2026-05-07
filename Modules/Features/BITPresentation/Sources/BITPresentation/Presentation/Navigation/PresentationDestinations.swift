import BITCredential
import BITTheming
import NavigatorUI
import SwiftUI

public enum PresentationDestinations: NavigationDestination {
  case declinePresentation(PresentationRequestContext)
  case compatibleCredentials(PresentationRequestContext)
  case requestReview(PresentationRequestContext)
  case badgeInformation(BadgeType)
  case error(ErrorDataset)
  case resultState(PresentationRequestResultState, PresentationRequestContext)
  case start(PresentationRequestContext)

  // MARK: Public

  public var method: NavigationMethod {
    switch self {
    case .compatibleCredentials,
         .declinePresentation,
         .error,
         .requestReview,
         .resultState,
         .start:
      .push
    case .badgeInformation:
      .managedSheet
    }
  }

  public var body: some View {
    switch self {
    case .declinePresentation(let context):
      DeclinePresentationView(context: context)
    case .compatibleCredentials(let context):
      CompatibleCredentialView(context: context)
    case .requestReview(let context):
      PresentationRequestReviewView(context: context)
    case .badgeInformation(let badgeType):
      BadgeInformationView(badgeType: badgeType)
    case .error(let dataset):
      ErrorView(dataset: dataset)
    case .resultState(let state, let context):
      PresentationRequestResultStateView(state: state, context: context)
    case .start(let context):
      if context.compatibleCredentials.isEmpty {
        DeclinePresentationView(context: context)
      } else if context.compatibleCredentials.count > 1 {
        CompatibleCredentialView(context: context)
      } else {
        PresentationRequestReviewView(context: context)
      }
    }
  }
}
