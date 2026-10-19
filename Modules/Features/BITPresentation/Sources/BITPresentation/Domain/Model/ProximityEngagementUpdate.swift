import BITOpenID
import Foundation

// MARK: - ProximityEngagementUpdate

public enum ProximityEngagementUpdate: Sendable {
  case qrCode(String)
  case request(requestObject: String, origin: String?)
}
