import BITActivity
import BITCore
import BITCredential
import BITL10n
import Foundation

// MARK: - ActivityDetailState

enum ActivityDetailState {
  case loading
  case result(Result)
  case error(Error)

  struct Result: Equatable, Changeable {
    let activity: ActivityCellViewModel
    let credential: ActivityCredentialViewModel
    let actor: Actor
  }

  struct Actor: Equatable {
    let title: String
    let viewModel: ActorHeaderViewModel
    let isReportAllowed: Bool
  }
}

extension ActivityDetailState.Result {
  init(_ activityDetail: ActivityDetail, colorScheme: String) {
    activity = ActivityCellViewModel(detail: activityDetail)
    credential = ActivityCredentialViewModel(detail: activityDetail, colorScheme: colorScheme)
    actor = ActivityDetailState.Actor(
      title: activityDetail.type.actorTitle,
      viewModel: activityDetail.actorHeaderViewModel,
      isReportAllowed: activityDetail.actorTrust != .trustedCheckApp)
  }
}

#if DEBUG
extension ActivityDetailState {
  struct Mock {
    static var result: ActivityDetailState {
      let activityDetail = ActivityDetail.Mock.trustedIssuance
      let activityViewModel = ActivityCellViewModel(detail: activityDetail)
      let credentialViewModel = ActivityCredentialViewModel(detail: activityDetail, colorScheme: "light")
      let viewState = ActivityDetailState.Result(
        activity: activityViewModel,
        credential: credentialViewModel,
        actor: Actor(title: "Actor title", viewModel: ActorHeaderViewModel(name: "Actor name", identity: .trusted), isReportAllowed: true))
      return .result(viewState)
    }
  }
}
#endif
