import Foundation

// MARK: - BadgeType

public enum BadgeType: Hashable {
  case actorInformation(type: ActorInformationBadgeType, actorName: String)
  case sensitiveData(isSensitive: Bool, claimName: String)
}
