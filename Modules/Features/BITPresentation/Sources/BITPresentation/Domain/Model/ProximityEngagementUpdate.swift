import BITOpenID
import Foundation

// MARK: - ProximityEngagementUpdate

public enum ProximityEngagementUpdate {
  case qrCode(String)
  case request(requestObject: String, origin: String?)
}
