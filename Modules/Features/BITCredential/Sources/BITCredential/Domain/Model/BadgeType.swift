import Foundation

public enum BadgeType {
  case actorInformation(type: ActorInformationBadgeType, actorName: String)
  case sensitiveData(isSensitive: Bool, claimName: String)
}
