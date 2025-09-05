import BITEntities

extension EIDRequestStatusStateEntity {

  init(_ state: EIDRequestStatus.State) {
    switch state {
    case .inQueue:
      self = .inQueue
    case .readyForOnlineSession:
      self = .readyForOnlineSession
    case .inTargetWalletPairing:
      self = .inTargetWalletPairing
    case .agentReview:
      self = .agentReview
    case .cancelled:
      self = .cancelled
    case .expired:
      self = .expired
    case .unknown:
      self = .unknown
    case .declined:
      self = .declined
    }
  }
}
