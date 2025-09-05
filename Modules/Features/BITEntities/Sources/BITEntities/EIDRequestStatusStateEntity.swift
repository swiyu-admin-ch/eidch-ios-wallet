import RealmSwift

public enum EIDRequestStatusStateEntity: String, PersistableEnum {
  case inQueue
  case readyForOnlineSession
  case inTargetWalletPairing
  case agentReview
  case cancelled
  case expired
  case unknown
  case declined
}
